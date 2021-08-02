// 单张纹理
// 使用单张纹理来作为物体漫反射颜色

Shader "Unity Shaders Book/Chapter 7/Single Texture" {
    Properties {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader {		
        Pass { 
            Tags { "LightMode"="ForwardBase" }
        
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            
            fixed4 _Color;
            sampler2D _MainTex;     // 声明 _MainTex 纹理
            float4 _MainTex_ST;     // 声明 _MainTex_ST，用于控制纹理缩放和平移
            fixed4 _Specular;
            float _Gloss;
            
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;    // 第一组纹理坐标
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };
            
            v2f vert(a2v v) {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                
                o.worldPos = mul(_Object2World, v.vertex).xyz;
                
                // 使用 _MainTex_ST 属性对顶点纹理坐标进行变换
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                
                // 计算反射率，使用纹理坐标对纹理进行采样
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                
                // 计算环境光，环境光与反射率相乘
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                
                // 计算漫反射，入射光与反射率相乘
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
                
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
                
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            
            ENDCG
        }
    } 
    FallBack "Specular"
}
