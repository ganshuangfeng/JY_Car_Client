// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyUnlit/CartoonShading1"
{
    Properties
    {
        _Color("Color Tint",Color)=(1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _Ramp("Ramp Texture",2D)="white"{}
        _Outline("Outline",Range(0,0.1))=0.02
        _Factor("Factor of Outline",Range(0,1))=0.5
        _OutlineColor("Outline Color",Color)=(0,0,0,1)
        _Specular("Specular",Color)=(1,1,1,1)
        _SpecularScale("Specular Scale",Range(0,0.1))=0.01
        _GuangZaoMainTex("GuangZao Tex",2d) = ""{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        //此Pass渲染描边
        Pass
        {
            //命名用于之后可重复调用
            NAME "OUTLINE"
            //描边只用渲染背面，挤出轮廓线，所以剔除正面
            Cull Front
            //开启深度写入，防止物体交叠处的描边被后渲染的物体盖住
            ZWrite On
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _Outline;
            float _Factor;
            fixed4 _OutlineColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                float3 pos=normalize(v.vertex.xyz);
                float3 normal=normalize(v.normal);

                //点积为了确定顶点对于几何中心的指向，判断此处的顶点是位于模型的凹处还是凸处
                float D=dot(pos,normal);
                //校正顶点的方向值，判断是否为轮廓线
                pos*=sign(D);
                //描边的朝向插值，偏向于法线方向还是顶点方向
                pos=lerp(normal,pos,_Factor);
                //将顶点向指定的方向挤出
                v.vertex.xyz+=pos*_Outline;
                o.vertex=UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(_OutlineColor.rgb,1);
            }
            ENDCG
        }
        //此Pass渲染卡通着色效果，主要运用半兰伯特光照模型配合渐变纹理
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            Cull Back
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            //引入阴影相关的宏
            #include "AutoLight.cginc"
            //引入预设的光照变量，如_LightColor0
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            sampler2D _Ramp;
            fixed4 _Specular;
            fixed _SpecularScale;
            float4 _MainTex_ST;

            struct appdata
            {
                float4 vertex:POSITION;
                float2 uv:TEXCOORD0;
                float2 uv2:TEXCOORD1;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
                float3 worldNormal:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
                float2 uv2:TEXCOORD3; 
            };

            v2f vert(appdata_full v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);
                o.uv2 = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;  
                o.worldNormal=mul(v.normal,(float3x3)unity_WorldToObject);
                o.worldPos=mul(unity_ObjectToWorld,v.vertex);

                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 worldNormal=normalize(i.worldNormal);
                fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir=normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 worldHalfDir=normalize(worldLightDir+worldViewDir);

                //计算材质反射率
                fixed4 c=tex2D(_MainTex,i.uv);
                fixed3 albedo=c.rgb*_Color.rgb;

                //计算环境光
                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;


                //计算半兰伯特漫反射系数，亮化处理，将结果从[-1,1]映射到[0,1]，以便作为渐变纹理的采样uv
                fixed diff=dot(worldNormal,worldLightDir);
                diff=(diff*0.5+0.5);

                //卡通渲染的核心内容，对漫反射进行区域色阶的离散变化
                fixed3 diffuse=_LightColor0.rgb*albedo*tex2D(_Ramp,float2(diff,diff)).rgb;

                //计算半兰伯特高光系数，并将高光边缘的过渡进行抗锯齿处理，系数越大，过渡越明显
                fixed spec=dot(worldNormal,worldHalfDir);
                fixed w=fwidth(spec)*3.0;

                //计算高光，在[-w,w]范围内平滑插值
                fixed3 specular=_Specular.rgb*smoothstep(-w,w,spec-(1-_SpecularScale))*step(0.0001,_SpecularScale);

                fixed shadow = 1; 

                float3 lightmapColor = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap,i.uv2));   
                fixed4 col = tex2D(_MainTex, i.uv);//第一个参数：纹理，第二个参数UV向量  
                col.rgb *= lightmapColor;
                return fixed4(ambient+diffuse+specular,1.0) * shadow;
            }
            ENDCG
        }

        Pass 
		{
            //此pass就是 从默认的fallBack中找到的 "LightMode" = "ShadowCaster" 产生阴影的Pass
			Tags { "LightMode" = "ShadowCaster" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile_instancing // allow instanced shadow pass for most of the shaders
			#include "UnityCG.cginc"

			struct v2f {
				V2F_SHADOW_CASTER;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2f vert( appdata_base v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}

			float4 frag( v2f i ) : SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG

		}

    }
    FallBack "Diffuse"
}