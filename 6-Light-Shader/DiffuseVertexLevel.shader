// 逐顶点漫反射光照模型
// 漫反射计算公式：
//      c_diffuse = ( c_light * m_diffuse )max(0, n·I)
//      1. c_light      入射光线颜色和强度
//      2. m_diffuse    材质漫反射系数
//      3. n            表面法线
//      4. I            光源方向

Shader "Unity Shaders Book/Chapter 6/Diffuse Vertex-Level" {
    Properties {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
    }
    SubShader {
        Pass { 
            // 指定光照模式，用于 unity 计算光源相关的变量
            // 在这里用于获取：
            //      光源的颜色和强度变量：_LightColor0
            //      光源方向：_WorldSpaceLightPos0
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc"
            
            // 定义材质漫反射系数
            fixed4 _Diffuse;
            
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR;
            };
            
            // 逐顶点光照会在顶点着色器中完成光照计算，将计算结构输出到片元着色器
            v2f vert(a2v v) {
                v2f o;
                // 计算顶点裁剪空间坐标
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                
                // 获取环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                
                // 计算法线，将法线从模型空间转换到世界空间
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)_World2Object));
                // 计算光照方向，获取世界空间的光线方向
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                // 计算漫反射，c_diffuse = ( c_light * m_diffuse )max(0, n·I)
                // saturate(x) 将 x 截取在 [0, 1] 范围中，如果 x 是一个矢量，那么对它的每一个分量进行操作
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
                
                // 计算颜色，混合环境光和漫反射
                o.color = ambient + diffuse;
                
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target {
                // 在片元着色器直接使用顶点着色器的计算结果
                return fixed4(i.color, 1.0);
            }
            
            ENDCG
        }
    }
    FallBack "Diffuse"
}
