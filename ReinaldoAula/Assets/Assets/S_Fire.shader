Shader "Custom/Fire_NoTexture_Mesh_Inverted"
{
    Properties
    {
        [Header(Colors)]
        _ColorBase ("Cor Base", Color) = (1.0, 0.8, 0.0, 1) 
        _ColorTop ("Cor Complementar", Color) = (1.0, 0.0, 0.0, 1)  
        
        [Header(Animation)]
        _Speed ("Flag Speed", Range(0, 20)) = 10.0
        _Amount ("Wobble Amount", Range(0, 1)) = 0.2
        _Chaos ("Chaos Factor", Range(1, 5)) = 3.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100
        Cull Off

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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 color : TEXCOORD1;
            };

            fixed4 _ColorBase;
            fixed4 _ColorTop;
            float _Speed;
            float _Amount;
            float _Chaos;

            v2f vert (appdata v)
            {
                v2f o;
                
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);

                // movimentacao da bandeira
                float wobbleX = sin(_Time.y * _Speed + worldPos.y * _Chaos);
                float wobbleZ = cos(_Time.y * _Speed * 0.8 + worldPos.y * _Chaos);
                
                float invertedUV = 1.0 - v.uv.y;
                float heightFactor = invertedUV * invertedUV;

                v.vertex.x += wobbleX * _Amount * heightFactor;
                v.vertex.z += wobbleZ * _Amount * heightFactor;
                v.vertex.y += sin(_Time.y * _Speed * 2.0) * (_Amount * 0.2) * heightFactor;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // gradiente simples
                fixed3 finalColor = lerp(_ColorBase.rgb, _ColorTop.rgb, i.uv.y);
                float pulse = sin(_Time.y * 15.0) * 0.1 + 1.0;
                
                return fixed4(finalColor * pulse, 1.0);
            }
            ENDCG
        }
    }
}