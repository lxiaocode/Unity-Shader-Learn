// 透明度测试

Shader "Unity Shaders Book/Chapter 8/Alpha Test" {
    Properties {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
    }
    SubShader {
        // "Queue"="AlphaTest" 指定渲染队列
        // "IgnoreProjector"="True" 表示Shader不受到投影器的影响
        // "RenderType"="TransparentCutout" 表示Shader使用了透明度测试
        // 使用了透明度测试的Shader都应该在SubShader添加这三个标签
        Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
        
        Pass {
            Tags { "LightMode"="ForwardBase" }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc"
            
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _Cutoff;          // 用于调用 clip 进行透明度测试时使用的判断条件
            
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
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
                
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                
                // 对纹理进行采样
                fixed4 texColor = tex2D(_MainTex, i.uv);
                
                // 对纹理进行透明度测试，texColor.a - _Cutoff 为负数就会舍弃片元
                clip (texColor.a - _Cutoff);
                
                fixed3 albedo = texColor.rgb * _Color.rgb;
                
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
                
                return fixed4(ambient + diffuse, 1.0);
            }
            
            ENDCG
        }
    } 
    FallBack "Transparent/Cutout/VertexLit"
}
