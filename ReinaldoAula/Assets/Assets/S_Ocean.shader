Shader "Lit/WavyLit"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _WaveSpeed ("Wave Speed", Range(0, 5)) = 1.0
        _WaveStrength ("Wave Strength", Range(0, 0.1)) = 0.02
        _NormalStrength ("Normal Strength", Range(0, 2)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                UNITY_FOG_COORDS(3)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            float4 _MainTex_ST;
            float4 _NormalMap_ST;

            float _WaveSpeed;
            float _WaveStrength;
            float _NormalStrength;

            v2f vert (appdata v)
            {
                v2f o;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                // movimento de ondinhas
                float wave = sin(worldPos.x * 2.0 + _Time.y * _WaveSpeed) * _WaveStrength +
                             cos(worldPos.z * 2.0 + _Time.y * _WaveSpeed) * _WaveStrength;

                v.vertex.y += wave; // altera a altura do vértice
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = worldPos;

                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // luz (acho que nao ta funcionando)
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                // lê normal map e aplica intensidade
                float3 normalTex = UnpackNormal(tex2D(_NormalMap, TRANSFORM_TEX(i.uv, _NormalMap)));
                normalTex = normalize(lerp(float3(0,0,1), normalTex, _NormalStrength));
                float3 worldNormal = normalize(i.worldNormal + normalTex * 0.5);

                float bright = saturate(dot(worldNormal, lightDir));

                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= bright;

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDHLSL
        }
    }
}
