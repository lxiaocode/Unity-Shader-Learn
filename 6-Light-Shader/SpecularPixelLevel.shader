// 逐像素高光反射光照模型
// 高光反射计算公式：
//      c_specular = ( c_light * m_specular )max(0, v·r)^m_gloass
//      1. c_light      入射光线颜色和强度
//      2. m_specular   材质高光反射系数
//      3. v            视角方向
//      4. r            反射方向
//      5. m_gloass     高光区域大小

Shader "Unity Shaders Book/Chapter 6/Specular Pixel-Level" {
    Properties {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader {
        Pass { 
            Tags { "LightMode"="ForwardBase" }
        
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            // 包含内置文件 Lighting.cginc，用于获取 unity 内置变量
            #include "Lighting.cginc"
            
            fixed4 _Diffuse;    // 定义材质漫反射系数
            fixed4 _Specular;   // 控制高光反射颜色
            float _Gloss;       // 控制高光区域大小
            
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };
            
            // 逐像素光照会在顶点着色器中完成必要的参数计算，用于提供给片元着色器进行光照计算
            v2f vert(a2v v) {
                v2f o;
                // 计算顶点裁剪空间坐标
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                
                // 计算法线，将法线从模型空间转换到世界空间
                o.worldNormal = mul(v.normal, (float3x3)_World2Object);
                // 计算顶点世界空间坐标
                o.worldPos = mul(_Object2World, v.vertex).xyz;
                
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
                
                // 计算漫反射，c_diffuse = ( c_light * m_diffuse )max(0, n·I)
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
                
                // 计算反射方向，reflect(i, n) 给定入射方向 i 和法线方向 n 计算出反射方向
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                // 计算视角方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                // 计算高光反射，c_specular = ( c_light * m_specular )max(0, v·r)^m_gloass
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
                
                // 混合环境光、漫反射和高光反射
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            
            ENDCG
        }
    } 
    FallBack "Specular"
}
