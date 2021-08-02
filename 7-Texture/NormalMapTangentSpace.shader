// 法线纹理
// 再切线空间下计算光照模型
// 基本思路：
//      在片元着色器中通过纹理采样得到切线空间下的法线，
//      然后再与切线空间下的视角方向、光照方向等进行计算，得到最终的光照结果。

Shader "Unity Shaders Book/Chapter 7/Normal Map In Tangent Space" {
    Properties {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1.0
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
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;     // 声明法线纹理
            float4 _BumpMap_ST;     // 声明法线纹理缩放平移属性
            float _BumpScale;       // 用于控制凹凸程度
            fixed4 _Specular;
            float _Gloss;
            
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;       // 获取顶点切线
                float4 texcoord : TEXCOORD0;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 lightDir: TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                
                // xy 分量存储了 _MainTex 的纹理坐标，zw 分量存储了 _BumpMap 的纹理坐标
                // 使用 _ST 属性对纹理坐标进行变换
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                // 计算副法线
                float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
                // 计算从模型空间到切线空间的变换矩阵
                float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

                // 计算切线空间下的视角方向和光线方向
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target {				
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);
                
                // 对法线纹理进行采样
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                fixed3 tangentNormal;

                tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                
                // 使用法线纹理中的法线进行漫反射计算
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                // 使用法线纹理中的法线进行高光反射计算
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);
                
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            
            ENDCG
        }
    } 
    FallBack "Specular"
}
