Shader "Unity Shaders Book/Chapter 5/Simple Shader" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
	}
	SubShader {
        Pass {
            CGPROGRAM

            // 定义顶点着色器函数和片元着色器其函数
            #pragma vertex vert
            #pragma fragment frag
            
            // 定义变量，与 Properties 语义块一一对应
            uniform fixed4 _Color;

            // 定义顶点着色器输入结构体
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };
            
            // 定义顶点着色器输出结构体，用于与片元着色器进行通信
            struct v2f {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR0;
            };
            
            // 顶点着色器
            v2f vert(a2v v) {
            	v2f o;
                // 将顶点坐标从模型空间转换到裁切空间
            	o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                // 计算顶点颜色
            	o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
                return o;
            }

            // 片元着色器
            fixed4 frag(v2f i) : SV_Target {
            	fixed3 c = i.color;
            	c *= _Color.rgb;
                return fixed4(c, 1.0);
            }

            ENDCG
        }
    }
}
