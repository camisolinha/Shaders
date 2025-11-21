Shader "Custom/S_Grass"
{
    Properties
    {
        [Header(Colors)]
        _ColorBot ("Color Base", Color) = (0.0, 0.3, 0.0, 1)
        _ColorTop ("Color Top", Color) = (0.3, 0.9, 0.2, 1)
        
        [Header(Wind)]
        _WindSpeed ("Wind Speed", Range(0, 10)) = 3.0
        _WindStrength ("Wind Strength", Range(0, 1.0)) = 0.2
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off // pra mosstra os dois lados

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
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // gradiante
                return lerp(_ColorBot, _ColorTop, i.uv.y);
            }
            ENDCG
        }
    }
}