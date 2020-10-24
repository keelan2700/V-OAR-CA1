// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Mtree/Billboard"
{
	Properties
	{
		[Header(Albedo)]_Color("Color", Color) = (1,1,1,1)
		[Header(Wind)]_GlobalWindInfluence1("Global Wind Influence", Range( 0 , 1)) = 1
		_MainTex("Albedo", 2D) = "white" {}
		[Enum(Off,0,Front,1,Back,2)]_CullMode("Cull Mode", Int) = 2
		_Cutoff("Cutoff", Range( 0 , 1)) = 0.5
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
		[Header(Forward Rendering Options)]
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Reflections", Float) = 1.0
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" }
		Cull [_CullMode]
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
		#pragma shader_feature _GLOSSYREFLECTIONS_OFF
		#pragma instancing_options procedural:setup
		#pragma multi_compile GPU_FRUSTUM_ON __
		#include "VS_indirect.cginc"
		#pragma multi_compile __ LOD_FADE_CROSSFADE
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPosition;
		};

		uniform int _CullMode;
		uniform int BillboardWindEnabled;
		uniform float _WindStrength;
		uniform float _GlobalWindInfluence1;
		uniform float _RandomWindOffset;
		uniform float _WindPulse;
		uniform float _WindDirection;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _Color;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform half _Cutoff;


		float2 DirectionalEquation( float _WindDirection )
		{
			float d = _WindDirection * 0.0174532924;
			float xL = cos(d) + 1 / 2;
			float zL = sin(d) + 1 / 2;
			return float2(zL,xL);
		}


		inline float Dither8x8Bayer( int x, int y )
		{
			const float dither[ 64 ] = {
				 1, 49, 13, 61,  4, 52, 16, 64,
				33, 17, 45, 29, 36, 20, 48, 32,
				 9, 57,  5, 53, 12, 60,  8, 56,
				41, 25, 37, 21, 44, 28, 40, 24,
				 3, 51, 15, 63,  2, 50, 14, 62,
				35, 19, 47, 31, 34, 18, 46, 30,
				11, 59,  7, 55, 10, 58,  6, 54,
				43, 27, 39, 23, 42, 26, 38, 22};
			int r = y * 8 + x;
			return dither[r] / 64; // same # of instructions as pre-dividing due to compiler magic
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 VAR_VertexPosition21_g10 = mul( unity_ObjectToWorld, float4( ase_vertex3Pos , 0.0 ) ).xyz;
			float3 break109_g10 = VAR_VertexPosition21_g10;
			float temp_output_46_0_g10 = ( _WindStrength * _GlobalWindInfluence1 );
			float VAR_WindStrength43_g10 = temp_output_46_0_g10;
			float4 transform21_g11 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float2 appendResult22_g11 = (float2(transform21_g11.x , transform21_g11.z));
			float dotResult2_g11 = dot( ( appendResult22_g11 + float2( 0,0 ) ) , float2( 12.9898,78.233 ) );
			float lerpResult8_g11 = lerp( 0.8 , ( ( _RandomWindOffset / 2.0 ) + 0.9 ) , frac( ( sin( dotResult2_g11 ) * 43758.55 ) ));
			float VAR_RandomTime16_g10 = ( _Time.x * lerpResult8_g11 );
			float temp_output_33_0_g10 = ( sin( ( ( VAR_RandomTime16_g10 * 40.0 ) - ( VAR_VertexPosition21_g10.z / 15.0 ) ) ) * 0.5 );
			float FUNC_Turbulence36_g10 = temp_output_33_0_g10;
			float temp_output_50_0_g10 = ( VAR_WindStrength43_g10 * ( 1.0 + sin( ( ( ( ( VAR_RandomTime16_g10 * 2.0 ) + FUNC_Turbulence36_g10 ) - ( VAR_VertexPosition21_g10.z / 50.0 ) ) - ( v.color.r / 20.0 ) ) ) ) * sqrt( v.color.r ) * 0.2 * _WindPulse );
			float FUNC_Angle73_g10 = temp_output_50_0_g10;
			float VAR_SinA80_g10 = sin( FUNC_Angle73_g10 );
			float VAR_CosA78_g10 = cos( FUNC_Angle73_g10 );
			float _WindDirection164_g10 = _WindDirection;
			float2 localDirectionalEquation164_g10 = DirectionalEquation( _WindDirection164_g10 );
			float2 break165_g10 = localDirectionalEquation164_g10;
			float VAR_xLerp83_g10 = break165_g10.x;
			float lerpResult118_g10 = lerp( break109_g10.x , ( ( break109_g10.y * VAR_SinA80_g10 ) + ( break109_g10.x * VAR_CosA78_g10 ) ) , VAR_xLerp83_g10);
			float3 break98_g10 = VAR_VertexPosition21_g10;
			float3 break105_g10 = VAR_VertexPosition21_g10;
			float VAR_zLerp95_g10 = break165_g10.y;
			float lerpResult120_g10 = lerp( break105_g10.z , ( ( break105_g10.y * VAR_SinA80_g10 ) + ( break105_g10.z * VAR_CosA78_g10 ) ) , VAR_zLerp95_g10);
			float3 appendResult122_g10 = (float3(lerpResult118_g10 , ( ( break98_g10.y * VAR_CosA78_g10 ) - ( break98_g10.z * VAR_SinA80_g10 ) ) , lerpResult120_g10));
			float3 FUNC_vertexPos123_g10 = appendResult122_g10;
			float3 ifLocalVar38 = 0;
			if( BillboardWindEnabled > 0.0 )
				ifLocalVar38 = ase_vertex3Pos;
			else if( BillboardWindEnabled == 0.0 )
				ifLocalVar38 = mul( unity_WorldToObject, float4( FUNC_vertexPos123_g10 , 0.0 ) ).xyz;
			v.vertex.xyz = ifLocalVar38;
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode3 = tex2D( _MainTex, uv_MainTex );
			o.Albedo = ( tex2DNode3 * _Color ).rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			clip( tex2DNode3.a - _Cutoff);
			float temp_output_41_0_g12 = tex2DNode3.a;
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen45_g12 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither45_g12 = Dither8x8Bayer( fmod(clipScreen45_g12.x, 8), fmod(clipScreen45_g12.y, 8) );
			dither45_g12 = step( dither45_g12, unity_LODFade.x );
			#ifdef LOD_FADE_CROSSFADE
				float staticSwitch40_g12 = ( temp_output_41_0_g12 * dither45_g12 );
			#else
				float staticSwitch40_g12 = temp_output_41_0_g12;
			#endif
			o.Alpha = staticSwitch40_g12;
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=17600
94;330;1343;379;874.332;-246.0834;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;1;-1354.891,4.554405;Inherit;False;1279.983;871.9046;;15;12;6;9;10;4;3;8;2;23;25;28;38;40;41;42;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;2;-1304.891,54.55442;Float;True;Property;_MainTex;Albedo;3;0;Create;False;0;0;False;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;3;-985.0397,68.42551;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;4;-953.6189,434.1565;Half;False;Property;_Cutoff;Cutoff;5;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;23;-700.8624,592.0113;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;25;-750.2974,520.1067;Inherit;False;Global;BillboardWindEnabled;BillboardWindEnabled;3;1;[Enum];Create;True;2;On;0;Off;1;0;False;0;0;1;0;1;INT;0
Node;AmplifyShaderEditor.ColorNode;8;-894.0508,258.5437;Inherit;False;Property;_Color;Color;0;0;Create;True;0;0;False;1;Header(Albedo);1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;41;-1203.572,671.2121;Inherit;False;Mtree Wind Main;1;;10;7b8005d279c29b544bf7997a1d0d05d6;1,166,0;0;6;FLOAT3;0;FLOAT;151;FLOAT;148;FLOAT;147;FLOAT;146;FLOAT2;153
Node;AmplifyShaderEditor.ClipNode;12;-525.8605,372.2194;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;38;-350.5879,584.4824;Inherit;False;False;5;0;INT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-523.2556,225.2081;Inherit;False;Property;_Metallic;Metallic;6;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-617.0268,139.8965;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.IntNode;28;-1288.554,370.3961;Inherit;False;Property;_CullMode;Cull Mode;4;1;[Enum];Create;True;3;Off;0;Front;1;Back;2;0;True;0;2;0;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-1298.6,284.0134;Inherit;False;Constant;_MaskClipValue;Mask Clip Value;14;1;[HideInInspector];Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-522.0943,298.1364;Inherit;False;Property;_Smoothness;Smoothness;7;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;42;-264.332,378.0834;Inherit;False;LOD CrossFade;-1;;12;04f063bd39e5c7349bef37691158654e;1,44,1;1;41;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;39;-48.5773,89.05838;Float;False;True;-1;2;;0;0;Standard;Mtree/Billboard;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;-1;-1;-1;0;False;0;0;True;28;-1;0;True;6;3;Pragma;instancing_options procedural:setup;False;;Custom;Pragma;multi_compile GPU_FRUSTUM_ON __;False;;Custom;Include;VS_indirect.cginc;False;a6d16d0571c954c4bbcc7edb6344bb7c;Custom;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;2;0
WireConnection;12;0;3;4
WireConnection;12;1;3;4
WireConnection;12;2;4;0
WireConnection;38;0;25;0
WireConnection;38;2;23;0
WireConnection;38;3;41;0
WireConnection;9;0;3;0
WireConnection;9;1;8;0
WireConnection;42;41;12;0
WireConnection;39;0;9;0
WireConnection;39;3;40;0
WireConnection;39;4;10;0
WireConnection;39;9;42;0
WireConnection;39;11;38;0
ASEEND*/
//CHKSM=34E74AA569E1461656257302028BD539C5128A63