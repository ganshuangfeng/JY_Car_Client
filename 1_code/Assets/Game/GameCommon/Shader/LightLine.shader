Shader "Custom/LightLine"{
    Properties{
        _Scale("内发光颜色范围控制",Range(1,8))=1
        _Scale2("外轮廓颜色范围控制",Range(1,8))=1
        _MainTex("贴图1",2D)="white"{}
        _ScaleColor("内发光颜色",Color)=(1,1,1,1)
        _ScaleColor2("外轮廓颜色",Color)=(1,1,1,1)
        _outline("轮廓范围",Range(0,1))=0.1
    }
    SubShader{
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType "="Transparent"}
 
                //外扩散发光
            pass{
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "Unitycg.cginc"
            sampler2D _MainTex;
            fixed4 _ScaleColor;
            fixed4 _ScaleColor2;
            fixed _outline;
            struct a2v{
                float4 vertex:POSITION;
                float3 normal:NORMAL;
 
            };
            struct v2f{
                float4 pos:SV_POSITION;
                float3 Wnormal:TEXCOORD0;
                float3 Wvertex:TEXCOORD1;
 
            };
            v2f vert(a2v v){
                v.vertex.xyz+=v.normal*_outline;
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.Wnormal=UnityObjectToWorldNormal(v.normal);
                o.Wvertex=mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }
            float _Scale;
            float _Scale2;
            fixed4 frag(v2f f):SV_TARGET{
                fixed3 WorldNormal=normalize(f.Wnormal);
                fixed3 ViewDir=normalize(_WorldSpaceCameraPos.xyz-f.Wvertex.xyz);
                fixed bright=max(0,dot(WorldNormal,ViewDir));
                bright=pow(bright,_Scale2);
                _ScaleColor2.a=_ScaleColor2.a*bright;
 
                return fixed4(_ScaleColor2);
            }
            ENDCG
        }
 
        //===============================================================================
//第2个pass，内发光
        pass{
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "Unitycg.cginc"
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _ScaleColor;
            struct a2v{
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 texcoord:TEXCOORD0;
            };
            struct v2f{
                float4 pos:SV_POSITION;
                float3 Wnormal:TEXCOORD0;
                float3 Wvertex:TEXCOORD1;
                float2 uv:TEXCOORD2;
 
            };
            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.Wnormal=UnityObjectToWorldNormal(v.normal);
                o.Wvertex=mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
                return o;
            }
            float _Scale;
            fixed4 frag(v2f f):SV_TARGET{
                fixed4 texcolor=tex2D(_MainTex,f.uv);
 
                fixed3 WorldNormal=normalize(f.Wnormal);
                fixed3 ViewDir=normalize(_WorldSpaceCameraPos.xyz-f.Wvertex.xyz);
                fixed bright=1.0-max(0,dot(WorldNormal,ViewDir));
                bright=pow(bright,_Scale);
                fixed4 edge=_ScaleColor*bright;
                fixed3 AddColor=edge.rgb+texcolor.rgb;
                return fixed4(AddColor,texcolor.a);
            }
            ENDCG
        }
 
    }
}