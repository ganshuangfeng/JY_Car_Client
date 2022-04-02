// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// 注意：手动更改此数据可能会妨碍您在 Shader Forge 中打开它
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:1,cusa:True,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:False,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:9361,x:34485,y:33002,varname:node_9361,prsc:2|custl-4050-OUT,alpha-6873-OUT;n:type:ShaderForge.SFN_Tex2d,id:2011,x:33300,y:33389,ptovrint:False,ptlb:sg,ptin:_sg,varname:node_2011,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:c73ea34459b5dd74d870d14b6eefc4c3,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:3353,x:33555,y:33294,varname:node_3353,prsc:2|A-2011-RGB,B-2011-A;n:type:ShaderForge.SFN_Vector1,id:5834,x:33327,y:33145,varname:node_5834,prsc:2,v1:5;n:type:ShaderForge.SFN_Multiply,id:2908,x:33718,y:33105,varname:node_2908,prsc:2|A-2917-OUT,B-3353-OUT;n:type:ShaderForge.SFN_Slider,id:6010,x:33125,y:32980,ptovrint:False,ptlb:liangdu,ptin:_liangdu,varname:node_6010,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.4444444,max:1;n:type:ShaderForge.SFN_Multiply,id:2917,x:33557,y:33017,varname:node_2917,prsc:2|A-6010-OUT,B-5834-OUT;n:type:ShaderForge.SFN_Color,id:6619,x:33701,y:33248,ptovrint:False,ptlb:yanse,ptin:_yanse,varname:node_6619,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Multiply,id:9700,x:34028,y:33169,varname:node_9700,prsc:2|A-2908-OUT,B-6619-RGB;n:type:ShaderForge.SFN_VertexColor,id:9790,x:33860,y:33352,varname:node_9790,prsc:2;n:type:ShaderForge.SFN_Multiply,id:6873,x:34081,y:33498,varname:node_6873,prsc:2|A-9790-A,B-2011-A;n:type:ShaderForge.SFN_Multiply,id:4050,x:34249,y:33169,varname:node_4050,prsc:2|A-9700-OUT,B-6873-OUT;proporder:2011-6010-6619;pass:END;sub:END;*/

Shader "Unlit/ADD (SoftClip)" {
    Properties {
        _sg ("sg", 2D) = "white" {}
        _liangdu ("liangdu", Range(0, 1)) = 0.4444444
        _yanse ("yanse", Color) = (1,1,1,1)
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
            "CanUseSpriteAtlas"="True"
            "PreviewType"="Plane"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend One One
            ZWrite On
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            //#pragma only_renderers d3d9 d3d11 glcore gles gles3 metal d3d11_9x xboxone ps4 psp2 n3ds wiiu 
            #pragma target 3.0
            uniform sampler2D _sg; uniform float4 _sg_ST;
            uniform float _liangdu;
            uniform float4 _yanse;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
                UNITY_FOG_COORDS(1)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
                float4 _sg_var = tex2D(_sg,TRANSFORM_TEX(i.uv0, _sg));
                float node_6873 = (i.vertexColor.a*_sg_var.a);
                float3 finalColor = ((((_liangdu*5.0)*(_sg_var.rgb*_sg_var.a))*_yanse.rgb)*node_6873);
                fixed4 finalRGBA = fixed4(finalColor,node_6873);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
