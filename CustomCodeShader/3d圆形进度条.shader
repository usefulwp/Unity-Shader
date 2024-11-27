Shader "Custom/CircleEdgeProgressShader"
{
    Properties
    {
        _Current("Current", Range(0, 100)) = 0
        _AlbedoColor("Albedo Color", Color) = (1, 1, 1, 1)
        _GradientTexture("Gradient Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float _Current;
            float4 _AlbedoColor;
            sampler2D _GradientTexture; // 添加纹理采样器

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // 保持原始颜色
                fixed4 color = _AlbedoColor;

                // 计算当前像素与圆心的距离
                float2 pos = i.uv - float2(0.5, 0.5); // 圆心在(0.5, 0.5)
                float dist = length(pos); // 计算到圆心的距离

                // 根据当前进度计算角度
                float progress = _Current / 100.0; // 将_current转换为0-1范围
                float angle = progress * 360.0; // 当前进度对应的角度
                float angleEdge = atan2(pos.y, pos.x) * (180.0 / 3.14159) + 180.0; // 将弧度转换为角度

                // 判断当前像素是否在圆内并且填充进度
                if (dist < 0.5) // 如果在圆内
                {
                    // 只有在边缘范围内才会有颜色变化
                    if (dist > 0.45) // 你可以根据需要调整这个值，控制边缘的宽度
                    {
                        // 判断该点的角度是否小于当前进度的角度
                        if (angleEdge < angle)
                        {
                            // 使用遮罩纹理进行颜色采样
                            float mask = tex2D(_GradientTexture, i.uv).a; // 使用纹理的 alpha 作为遮罩
                            color.a *= mask; // 将遮罩应用到 alpha 上
                            return color; // 在进度范围内，返回颜色
                        }
                        else
                        {
                            return fixed4(1, 1, 1, 1); // 否则返回透明
                        }
                    }
                }

                // 圆外部区域透明
                return fixed4(1, 1,1, 1);
            }
            ENDCG
        }
    }
}
