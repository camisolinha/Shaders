Shader "Custom/S_Leaf"
{
    Properties
    {
        [Header(Texture)]
        _MainTex ("Leaf Texture", 2D) = "white" {}
        _Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5

        [Header(Colors)]
        _ColorBot ("Color Base", Color) = (0.0, 0.3, 0.0, 1)
        _ColorTop ("Color Top", Color) = (0.3, 0.9, 0.2, 1)
        
        [Header(Wind)]
        _WindSpeed ("Wind Speed", Range(0, 10)) = 3.0
        _WindStrength ("Wind Strength", Range(0, 1.0)) = 0.2
    }

    SubShader
    {
        Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest" }
        LOD 100
        Cull Off // mosstra frente e verso

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _Cutoff;

            fixed4 _ColorBot;
            fixed4 _ColorTop;
            float _WindSpeed;
            float _WindStrength;

            v2f vert (appdata v)
            {
                v2f o;

                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);

                float wind = sin(_Time.y * _WindSpeed + worldPos.x);

                v.vertex.x += wind * _WindStrength * v.uv.y; 
                
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 texColor = tex2D(_MainTex, i.uv);
                clip(texColor.a - _Cutoff);
                fixed4 gradientColor = lerp(_ColorBot, _ColorTop, i.uv.y);

                return texColor * gradientColor;
            }
            ENDCG
        }
    }
}