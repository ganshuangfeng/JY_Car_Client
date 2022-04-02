// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:33255,y:33070,varname:node_3138,prsc:2|emission-6379-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:32236,y:32609,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_7241,prsc:2,glob:False,taghide:False,taghdr:True,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_VertexColor,id:1955,x:32203,y:32780,varname:node_1955,prsc:2;n:type:ShaderForge.SFN_Tex2d,id:2513,x:32222,y:32951,ptovrint:False,ptlb:tex(R),ptin:_texR,varname:node_2513,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-9190-OUT;n:type:ShaderForge.SFN_Tex2d,id:4976,x:32233,y:33206,ptovrint:False,ptlb:mask(R),ptin:_maskR,varname:node_4976,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-5729-OUT;n:type:ShaderForge.SFN_Multiply,id:6696,x:32607,y:32965,varname:node_6696,prsc:2|A-7241-RGB,B-1955-RGB,C-4976-R,D-2513-A;n:type:ShaderForge.SFN_Time,id:7763,x:30974,y:32509,varname:node_7763,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:8687,x:30961,y:32376,ptovrint:False,ptlb:u,ptin:_u,varname:node_8687,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:7969,x:30947,y:32691,ptovrint:False,ptlb:v,ptin:_v,varname:node_7969,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:4054,x:31204,y:32448,varname:node_4054,prsc:2|A-8687-OUT,B-7763-T;n:type:ShaderForge.SFN_Multiply,id:9107,x:31216,y:32618,varname:node_9107,prsc:2|A-7763-T,B-7969-OUT;n:type:ShaderForge.SFN_TexCoord,id:1781,x:31204,y:32245,varname:node_1781,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Add,id:6464,x:31454,y:32353,varname:node_6464,prsc:2|A-1781-U,B-4054-OUT;n:type:ShaderForge.SFN_Add,id:5964,x:31477,y:32573,varname:node_5964,prsc:2|A-1781-V,B-9107-OUT;n:type:ShaderForge.SFN_Append,id:7483,x:31682,y:32573,varname:node_7483,prsc:2|A-6464-OUT,B-5964-OUT;n:type:ShaderForge.SFN_Multiply,id:6379,x:32810,y:32789,varname:node_6379,prsc:2|A-7241-A,B-6696-OUT,C-2513-RGB,D-1955-A;n:type:ShaderForge.SFN_Time,id:4362,x:30932,y:33770,varname:node_4362,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:1007,x:30919,y:33637,ptovrint:False,ptlb:u_mask,ptin:_u_mask,varname:_u_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:4748,x:30908,y:33990,ptovrint:False,ptlb:v_mask,ptin:_v_mask,varname:_v_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:2020,x:31162,y:33743,varname:node_2020,prsc:2|A-1007-OUT,B-4362-T;n:type:ShaderForge.SFN_Multiply,id:4055,x:31162,y:33944,varname:node_4055,prsc:2|A-4362-T,B-4748-OUT;n:type:ShaderForge.SFN_TexCoord,id:5821,x:31162,y:33529,varname:node_5821,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Add,id:1346,x:31412,y:33614,varname:node_1346,prsc:2|A-5821-U,B-2020-OUT;n:type:ShaderForge.SFN_Add,id:8219,x:31435,y:33834,varname:node_8219,prsc:2|A-5821-V,B-4055-OUT;n:type:ShaderForge.SFN_Append,id:5729,x:31684,y:33782,varname:node_5729,prsc:2|A-1346-OUT,B-8219-OUT;n:type:ShaderForge.SFN_Tex2d,id:1977,x:31436,y:32805,ptovrint:False,ptlb:niuquTex,ptin:_niuquTex,varname:node_1977,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-914-OUT;n:type:ShaderForge.SFN_Add,id:9190,x:31885,y:32719,varname:node_9190,prsc:2|A-7483-OUT,B-6636-OUT;n:type:ShaderForge.SFN_Multiply,id:6636,x:31662,y:32850,varname:node_6636,prsc:2|A-1977-RGB,B-7478-OUT;n:type:ShaderForge.SFN_ValueProperty,id:7478,x:31436,y:32991,ptovrint:False,ptlb:niuqu,ptin:_niuqu,varname:node_7478,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Time,id:3241,x:30399,y:32955,varname:node_3241,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:160,x:30386,y:32822,ptovrint:False,ptlb:niuqu_U,ptin:_niuqu_U,varname:_u_mask_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:1074,x:30375,y:33175,ptovrint:False,ptlb:niuqu_V,ptin:_niuqu_V,varname:_v_mask_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:2172,x:30629,y:32928,varname:node_2172,prsc:2|A-160-OUT,B-3241-T;n:type:ShaderForge.SFN_Multiply,id:3469,x:30629,y:33129,varname:node_3469,prsc:2|A-3241-T,B-1074-OUT;n:type:ShaderForge.SFN_TexCoord,id:4024,x:30629,y:32714,varname:node_4024,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Add,id:9512,x:30879,y:32799,varname:node_9512,prsc:2|A-4024-U,B-2172-OUT;n:type:ShaderForge.SFN_Add,id:6544,x:30902,y:33019,varname:node_6544,prsc:2|A-4024-V,B-3469-OUT;n:type:ShaderForge.SFN_Append,id:914,x:31151,y:32967,varname:node_914,prsc:2|A-9512-OUT,B-6544-OUT;proporder:7241-2513-8687-7969-4976-1007-4748-1977-7478-160-1074;pass:END;sub:END;*/

Shader "Shader Forge/add_mask_uv" {
    Properties {
        [HDR]_Color ("Color", Color) = (1,1,1,1)
        _texR ("tex(R)", 2D) = "white" {}
        _u ("u", Float ) = 0
        _v ("v", Float ) = 0
        _maskR ("mask(R)", 2D) = "white" {}
        _u_mask ("u_mask", Float ) = 0
        _v_mask ("v_mask", Float ) = 0
        _niuquTex ("niuquTex", 2D) = "white" {}
        _niuqu ("niuqu", Float ) = 0
        _niuqu_U ("niuqu_U", Float ) = 0
        _niuqu_V ("niuqu_V", Float ) = 0
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend One One
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float4 _Color;
            uniform sampler2D _texR; uniform float4 _texR_ST;
            uniform sampler2D _maskR; uniform float4 _maskR_ST;
            uniform float _u;
            uniform float _v;
            uniform float _u_mask;
            uniform float _v_mask;
            uniform sampler2D _niuquTex; uniform float4 _niuquTex_ST;
            uniform float _niuqu;
            uniform float _niuqu_U;
            uniform float _niuqu_V;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
////// Lighting:
////// Emissive:
                float4 node_4362 = _Time;
                float2 node_5729 = float2((i.uv0.r+(_u_mask*node_4362.g)),(i.uv0.g+(node_4362.g*_v_mask)));
                float4 _maskR_var = tex2D(_maskR,TRANSFORM_TEX(node_5729, _maskR));
                float4 node_7763 = _Time;
                float4 node_3241 = _Time;
                float2 node_914 = float2((i.uv0.r+(_niuqu_U*node_3241.g)),(i.uv0.g+(node_3241.g*_niuqu_V)));
                float4 _niuquTex_var = tex2D(_niuquTex,TRANSFORM_TEX(node_914, _niuquTex));
                float3 node_9190 = (float3(float2((i.uv0.r+(_u*node_7763.g)),(i.uv0.g+(node_7763.g*_v))),0.0)+(_niuquTex_var.rgb*_niuqu));
                float4 _texR_var = tex2D(_texR,TRANSFORM_TEX(node_9190, _texR));
                float3 emissive = (_Color.a*(_Color.rgb*i.vertexColor.rgb*_maskR_var.r*_texR_var.a)*_texR_var.rgb*i.vertexColor.a);
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            struct VertexInput {
                float4 vertex : POSITION;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
