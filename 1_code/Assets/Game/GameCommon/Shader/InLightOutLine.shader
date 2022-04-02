Shader "Custom/InLightOutLine"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Width("Width",Range(0,10)) = 1
        _BloomColor("BloomColor",Color)=(1,1,1,1)
        _Strength("Strength",Range(0,10)) = 1
        _Power("Power",Range(0,10)) = 1
    }
    // ---------------------------【子着色器】---------------------------
    SubShader
    {
        // 渲染队列采用 透明
        Tags{
            "RenderType"="Transparent"
            "Queue" = "Transparent"
        }
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
		{
			//计算描边做法，检测像素上下左右各一个像素的alpha为0即判断该像素处于边缘
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float2 up_uv : TEXCOORD1;
				float2 down_uv : TEXCOORD2;
				float2 left_uv : TEXCOORD3;
				float2 right_uv : TEXCOORD4;
			};

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float _Width;
			float4 _BloomColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.up_uv = o.uv + float2(0, 1)*_Width*_MainTex_TexelSize.xy;
				o.down_uv = o.uv + float2(0, -1)*_Width*_MainTex_TexelSize.xy;
				o.left_uv = o.uv + float2(-1,0)*_Width*_MainTex_TexelSize.xy;
				o.right_uv = o.uv + float2(1, 0)*_Width*_MainTex_TexelSize.xy;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				float w = tex2D(_MainTex, i.up_uv).a * tex2D(_MainTex, i.down_uv).a *tex2D(_MainTex, i.left_uv).a *tex2D(_MainTex, i.right_uv).a;
				col.rgb = lerp(_BloomColor.rgb, col.rgb, w);
				return col;
			}
			ENDCG
		}

        Pass
		{
			//计算均值模糊的做法，3X3的像素卷积内透明像素越多，则(0,0)像素alpha值越低
			//采用了均值权重3x3的卷积算法 实际纹理采样为3*3*图像高度*图像长度
			Blend One One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag


			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv[9] : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float _Width;
			float4 _BloomColor;
			float _Strength;

			half CalculateAlphaSumAround(v2f i)
			{
				half alpha;
				half aSum = 0;
				_Strength /= 50;
				for (int it = 0; it < 9; it++)
				{
					alpha = tex2D(_MainTex, i.uv[it]).a;
					aSum += alpha * _Strength;
				}
				aSum = min(1, aSum);
				return aSum;
			}

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv[0] = v.uv + _MainTex_TexelSize.xy * half2(-1,-1)*_Width;
				o.uv[1] = v.uv + _MainTex_TexelSize.xy * half2(-1, 0)*_Width;
				o.uv[2] = v.uv + _MainTex_TexelSize.xy * half2(-1, 1)*_Width;
				o.uv[3] = v.uv + _MainTex_TexelSize.xy * half2(0, -1)*_Width;
				o.uv[4] = v.uv + _MainTex_TexelSize.xy * half2(0, -1)*_Width;
				o.uv[5] = v.uv + _MainTex_TexelSize.xy * half2(0, 0)*_Width;
				o.uv[6] = v.uv + _MainTex_TexelSize.xy * half2(1, -1)*_Width;
				o.uv[7] = v.uv + _MainTex_TexelSize.xy * half2(1, 0)*_Width;
				o.uv[8] = v.uv + _MainTex_TexelSize.xy * half2(1, 1)*_Width;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				half a = CalculateAlphaSumAround(i);
				return float4(_BloomColor.rgb*a,1);
			}
			ENDCG
		}

        Pass
        {
            //采用5X5卷积算子，分两个pass，将二维卷积核转化为两个一维卷积核计算
            //采用了卷积权重计算，先计算水平的pass
            Blend One One
            NAME "BLOOM_VERTICAL"
            CGPROGRAM
            #pragma vertex vertBloomVertical
            #pragma fragment fragBloom


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv[5] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _Width;
            float4 _BloomColor;
            float _Strength;
            float _Power;

            half CalculateAlphaSumAround(v2f i)
            {
                float weight[3] = { 0.4026,0.2442,0.0545 };
                half aSum = tex2D(_MainTex,i.uv[0]).a * weight[0] * _Strength;
                aSum += tex2D(_MainTex, i.uv[1]).a * weight[1] * _Strength;
                aSum += tex2D(_MainTex, i.uv[2]).a * weight[1] * _Strength;
                aSum += tex2D(_MainTex, i.uv[3]).a * weight[2] * _Strength;
                aSum += tex2D(_MainTex, i.uv[4]).a * weight[2] * _Strength;
                aSum = min(1, aSum);
                return aSum;
            }

            v2f vertBloomVertical(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv[0] = v.uv;
                o.uv[1] = v.uv + float2(_MainTex_TexelSize.x *1,0)*_Width;
                o.uv[2] = v.uv - float2( _MainTex_TexelSize.x *1,0)*_Width;
                o.uv[3] = v.uv + float2(_MainTex_TexelSize.x *2,0)*_Width;
                o.uv[4] = v.uv - float2(_MainTex_TexelSize.x *2,0)*_Width;
                return o;
            }

            fixed4 fragBloom(v2f i) : SV_Target
            {
                half a = CalculateAlphaSumAround(i);
                return float4(pow(_BloomColor.rgb*a, _Power),1);
            }
            ENDCG
        }

        Pass
        {
            //采用5X5卷积算子，分两个pass，将二维卷积核转化为两个一维卷积核计算
            //采用了卷积权重计算，后计算垂直的pass
            Blend One One
            NAME "BLOOM_HORIZONTAL"
            CGPROGRAM
            #pragma vertex vertBloomHorizontal
            #pragma fragment fragBloom


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv[5] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _Width;
            float4 _BloomColor;
            float _Strength;
            float _Power;

            half CalculateAlphaSumAround(v2f i)
            {
                float weight[3] = { 0.4026,0.2442,0.0545 };
                half aSum = tex2D(_MainTex,i.uv[0]).a * weight[0] * _Strength;
                aSum += tex2D(_MainTex, i.uv[1]).a * weight[1] * _Strength;
                aSum += tex2D(_MainTex, i.uv[2]).a * weight[1] * _Strength;
                aSum += tex2D(_MainTex, i.uv[3]).a * weight[2] * _Strength;
                aSum += tex2D(_MainTex, i.uv[4]).a * weight[2] * _Strength;
                aSum = min(1, aSum);
                return aSum;
            }

            v2f vertBloomHorizontal(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv[0] = v.uv;
                o.uv[1] = v.uv + float2(0,_MainTex_TexelSize.y *1)*_Width;
                o.uv[2] = v.uv - float2(0, _MainTex_TexelSize.y * 1)*_Width;
                o.uv[3] = v.uv + float2(0, _MainTex_TexelSize.y * 2)*_Width;
                o.uv[4] = v.uv - float2(0, _MainTex_TexelSize.y * 2)*_Width;
                return o;
            }

            fixed4 fragBloom(v2f i) : SV_Target
            {
                half a = CalculateAlphaSumAround(i);
                return float4(pow(_BloomColor.rgb*a, _Power),1);
            }
            ENDCG
        }
    }
}