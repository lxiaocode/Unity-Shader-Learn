// 半兰伯特光照模型
// 漫反射计算公式：
//      c_diffuse = ( c_light * m_diffuse )(0.5 * (n·I) + 0.5)
//      1. c_light      入射光线颜色和强度
//      2. m_diffuse    材质漫反射系数
//      3. n            表面法线
//      4. I            光源方向

Shader "Unity Shaders Book/Chapter 6/Half Lambert" {
    Properties {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
    }
    SubShader {
        Pass { 
            // 指定光照模式，用于 unity 计算光源相关的变量
            // 在这里用于计算：
            //      光源的颜色和强度变量：_LightColor0
            //      光源方向：_WorldSpaceLightPos0
            Tags { "LightMode"="ForwardBase" }
        
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            // 包含内置文件 Lighting.cginc，用于获取 unity 内置变量
            #include "Lighting.cginc"
            
            // 定义材质漫反射系数
            fixed4 _Diffuse;
            
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
            };
            
            // 逐像素光照会在顶点着色器中完成必要的参数计算，用于提供给片元着色器进行光照计算
            v2f vert(a2v v) {
                v2f o;
                // 计算顶点裁剪空间坐标
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                
                // 计算法线，将法线从模型空间转换到世界空间
                o.worldNormal = mul(v.normal, (float3x3)_World2Object);
                
                return o;
            }
            
            // 逐像素光照会在片元着色器中完成光照计算
            fixed4 frag(v2f i) : SV_Target {
                // 获取环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                
                // 计算法线，将法线从模型空间转换到世界空间
                fixed3 worldNormal = normalize(i.worldNormal);
                // 计算光照方向，获取世界空间的光线方向
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                
                // 计算漫反射，使用半兰伯特计算公式：
                // 		c_diffuse = ( c_light * m_diffuse )(0.5 * (n·I) + 0.5)
                fixed halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;
                
                // 计算颜色，混合环境光和漫反射
                fixed3 color = ambient + diffuse;
                
                return fixed4(color, 1.0);
            }
            
            ENDCG
        }
    } 
    FallBack "Diffuse"
}
