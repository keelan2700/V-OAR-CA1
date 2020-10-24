// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Mtree/Leaves"
{
	Properties
	{
		_GlobalTurbulenceInfluence("Global Turbulence Influence", Range( 0 , 1)) = 1
		[Enum(Leaves,0,Palm,1,Grass,2,Off,3)]_WindModeLeaves("Wind Mode Leaves", Int) = 0
		[Header(Albedo Texture)]_Color("Color", Color) = (1,1,1,1)
		[Header(Wind)]_GlobalWindInfluence1("Global Wind Influence", Range( 0 , 1)) = 1
		_MainTex("Albedo", 2D) = "white" {}
		[Enum(Off,0,Front,1,Back,2)]_CullMode("Cull Mode", Int) = 0
		[Enum(Flip,0,Mirror,1,None,2)]_DoubleSidedNormalMode("Double Sided Normal Mode", Int) = 2
		_Cutoff("Cutoff", Range( 0 , 1)) = 0.5
		[Header(Normal Texture)]_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("Normal Strength", Float) = 1
		[Header(Color Settings)]_Hue("Hue", Range( -0.5 , 0.5)) = 0
		_Value("Value", Range( 0 , 3)) = 1
		_Saturation("Saturation", Range( 0 , 2)) = 1
		_ColorVariation("Color Variation", Range( 0 , 0.3)) = 0.15
		[Header(Smoothness)]_Glossiness("Smoothness", Range( 0 , 1)) = 0
		_GlossinessVariance("Smoothness Variance", Range( 0 , 1)) = 0
		_GlossinessThreshold("Smoothness Threshold", Range( 0 , 1)) = 0
		[Header(Other Settings)]_OcclusionStrength("AO strength", Range( 0 , 1)) = 0.6
		_Metallic("Metallic", Range( 0 , 1)) = 0
		[Header(Translucency)]_Scale("Scale", Range( 0.001 , 8)) = 2
		_Power("Power", Range( 0.001 , 8)) = 2
		_Distortion("Distortion", Range( 0.001 , 8)) = 2
		[Enum(Global,0,Custom,1)]_LightSouce("Light Souce", Int) = 0
		_TranslucentColor("Translucent Color", Color) = (1,1,1,1)
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
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
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
			half ASEVFace : VFACE;
			float4 vertexColor : COLOR;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float4 screenPosition;
		};

		uniform int _WindModeLeaves;
		uniform float _WindStrength;
		uniform float _GlobalWindInfluence1;
		uniform float _RandomWindOffset;
		uniform float _WindPulse;
		uniform float _WindDirection;
		uniform float _WindTurbulence;
		uniform float _GlobalTurbulenceInfluence;
		uniform int _DoubleSidedNormalMode;
		uniform int _CullMode;
		uniform sampler2D _BumpMap;
		uniform float4 _BumpMap_ST;
		uniform half _BumpScale;
		uniform float4 _Color;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _ColorVariation;
		uniform half _Hue;
		uniform float _Saturation;
		uniform float _Value;
		uniform float _Distortion;
		uniform float _Power;
		uniform float _Scale;
		uniform int _LightSouce;
		uniform float4 _TranslucentColor;
		uniform float _Glossiness;
		uniform float _GlossinessVariance;
		uniform float _GlossinessThreshold;
		uniform float _Metallic;
		uniform half _OcclusionStrength;
		uniform half _Cutoff;


		float GetGeometricNormalVariance( float perceptualSmoothness , float3 geometricNormalWS , float screenSpaceVariance , float threshold )
		{
			#define PerceptualSmoothnessToRoughness(perceptualSmoothness) (1.0 - perceptualSmoothness) * (1.0 - perceptualSmoothness)
			#define RoughnessToPerceptualSmoothness(roughness) 1.0 - sqrt(roughness)
			float3 deltaU = ddx(geometricNormalWS);
			float3 deltaV = ddy(geometricNormalWS);
			float variance = screenSpaceVariance * (dot(deltaU, deltaU) + dot(deltaV, deltaV));
			float roughness = PerceptualSmoothnessToRoughness(perceptualSmoothness);
			// Ref: Geometry into Shading - http://graphics.pixar.com/library/BumpRoughness/paper.pdf - equation (3)
			float squaredRoughness = saturate(roughness * roughness + min(2.0 * variance, threshold * threshold)); // threshold can be really low, square the value for easier
			return RoughnessToPerceptualSmoothness(sqrt(squaredRoughness));
		}


		float2 DirectionalEquation( float _WindDirection )
		{
			float d = _WindDirection * 0.0174532924;
			float xL = cos(d) + 1 / 2;
			float zL = sin(d) + 1 / 2;
			return float2(zL,xL);
		}


		float3 If94_g318( int m_Switch , float3 m_Leaves , float3 m_Palm , float3 m_Grass , float3 m_None )
		{
			if(m_Switch == 0)
				return m_Leaves;
			if(m_Switch == 1)
				return m_Palm;
			if(m_Switch == 2);
				return m_Grass;
			if(m_Switch == 3)
				return m_None;
			return m_Leaves;
		}


		float3 If4_g315( float Mode , float Cull , float3 Flip , float3 Mirror , float3 None )
		{
			float3 OUT = None;
			if(Cull == 0){
			    if(Mode == 0)
			        OUT = Flip;
			    if(Mode == 1)
			        OUT = Mirror;
			    if(Mode == 2)
			        OUT == None;
			}else{
			    OUT = None;
			}
			return OUT;
		}


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		float3 RGBToHSV(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
			float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
			float d = q.x - min( q.w, q.y );
			float e = 1.0e-10;
			return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
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
			int m_Switch94_g318 = _WindModeLeaves;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 VAR_VertexPosition21_g316 = mul( unity_ObjectToWorld, float4( ase_vertex3Pos , 0.0 ) ).xyz;
			float3 break109_g316 = VAR_VertexPosition21_g316;
			float temp_output_46_0_g316 = ( _WindStrength * _GlobalWindInfluence1 );
			float VAR_WindStrength43_g316 = temp_output_46_0_g316;
			float4 transform21_g317 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float2 appendResult22_g317 = (float2(transform21_g317.x , transform21_g317.z));
			float dotResult2_g317 = dot( ( appendResult22_g317 + float2( 0,0 ) ) , float2( 12.9898,78.233 ) );
			float lerpResult8_g317 = lerp( 0.8 , ( ( _RandomWindOffset / 2.0 ) + 0.9 ) , frac( ( sin( dotResult2_g317 ) * 43758.55 ) ));
			float VAR_RandomTime16_g316 = ( _Time.x * lerpResult8_g317 );
			float temp_output_33_0_g316 = ( sin( ( ( VAR_RandomTime16_g316 * 40.0 ) - ( VAR_VertexPosition21_g316.z / 15.0 ) ) ) * 0.5 );
			float FUNC_Turbulence36_g316 = temp_output_33_0_g316;
			float temp_output_50_0_g316 = ( VAR_WindStrength43_g316 * ( 1.0 + sin( ( ( ( ( VAR_RandomTime16_g316 * 2.0 ) + FUNC_Turbulence36_g316 ) - ( VAR_VertexPosition21_g316.z / 50.0 ) ) - ( v.color.r / 20.0 ) ) ) ) * sqrt( v.color.r ) * 0.2 * _WindPulse );
			float FUNC_Angle73_g316 = temp_output_50_0_g316;
			float VAR_SinA80_g316 = sin( FUNC_Angle73_g316 );
			float VAR_CosA78_g316 = cos( FUNC_Angle73_g316 );
			float _WindDirection164_g316 = _WindDirection;
			float2 localDirectionalEquation164_g316 = DirectionalEquation( _WindDirection164_g316 );
			float2 break165_g316 = localDirectionalEquation164_g316;
			float VAR_xLerp83_g316 = break165_g316.x;
			float lerpResult118_g316 = lerp( break109_g316.x , ( ( break109_g316.y * VAR_SinA80_g316 ) + ( break109_g316.x * VAR_CosA78_g316 ) ) , VAR_xLerp83_g316);
			float3 break98_g316 = VAR_VertexPosition21_g316;
			float3 break105_g316 = VAR_VertexPosition21_g316;
			float VAR_zLerp95_g316 = break165_g316.y;
			float lerpResult120_g316 = lerp( break105_g316.z , ( ( break105_g316.y * VAR_SinA80_g316 ) + ( break105_g316.z * VAR_CosA78_g316 ) ) , VAR_zLerp95_g316);
			float3 appendResult122_g316 = (float3(lerpResult118_g316 , ( ( break98_g316.y * VAR_CosA78_g316 ) - ( break98_g316.z * VAR_SinA80_g316 ) ) , lerpResult120_g316));
			float3 FUNC_vertexPos123_g316 = appendResult122_g316;
			float3 IN_MainWind109_g318 = FUNC_vertexPos123_g316;
			float3 break39_g318 = IN_MainWind109_g318;
			float IN_Time112_g318 = VAR_RandomTime16_g316;
			float IN_Turbulence110_g318 = temp_output_33_0_g316;
			half FUNC_SinFunction42_g318 = sin( ( ( IN_Time112_g318 * 200.0 * ( 0.2 + v.color.g ) ) + ( v.color.g * 10.0 ) + IN_Turbulence110_g318 + ( mul( unity_ObjectToWorld, float4( ase_vertex3Pos , 0.0 ) ).xyz.z / 2.0 ) ) );
			float IN_Angle101_g318 = temp_output_50_0_g316;
			float IN_WindStrength72_g318 = temp_output_46_0_g316;
			float VAR_GlobalWindTurbulence45_g318 = ( _WindTurbulence * _GlobalTurbulenceInfluence );
			float3 appendResult40_g318 = (float3(break39_g318.x , ( break39_g318.y + ( FUNC_SinFunction42_g318 * v.color.b * ( IN_Angle101_g318 + ( IN_WindStrength72_g318 / 200.0 ) ) * VAR_GlobalWindTurbulence45_g318 ) ) , break39_g318.z));
			float3 OUT_Leaves44_g318 = appendResult40_g318;
			float3 m_Leaves94_g318 = OUT_Leaves44_g318;
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float3 appendResult60_g318 = (float3(( ase_normWorldNormal.x * v.color.g ) , ( ase_normWorldNormal.y / v.color.r ) , ( ase_normWorldNormal.z * v.color.g )));
			float3 OUT_Palm74_g318 = ( ( ( FUNC_SinFunction42_g318 * v.color.b * ( IN_Angle101_g318 + ( IN_WindStrength72_g318 / 200.0 ) ) * VAR_GlobalWindTurbulence45_g318 ) * appendResult60_g318 ) + IN_MainWind109_g318 );
			float3 m_Palm94_g318 = OUT_Palm74_g318;
			float temp_output_84_0_g318 = ( 0.0 * v.color.b * ( IN_Angle101_g318 + ( IN_WindStrength72_g318 / 200.0 ) ) );
			float2 IN_XZ_Lerp114_g318 = localDirectionalEquation164_g316;
			float2 break76_g318 = IN_XZ_Lerp114_g318;
			float lerpResult85_g318 = lerp( 0.0 , temp_output_84_0_g318 , break76_g318.x);
			float lerpResult87_g318 = lerp( 0.0 , temp_output_84_0_g318 , break76_g318.y);
			float3 appendResult83_g318 = (float3(( IN_MainWind109_g318.x + lerpResult85_g318 ) , 0.0 , ( 0.0 + lerpResult87_g318 )));
			float3 OUT_Grass93_g318 = appendResult83_g318;
			float3 m_Grass94_g318 = OUT_Grass93_g318;
			float3 m_None94_g318 = IN_MainWind109_g318;
			float3 localIf94_g318 = If94_g318( m_Switch94_g318 , m_Leaves94_g318 , m_Palm94_g318 , m_Grass94_g318 , m_None94_g318 );
			v.vertex.xyz = mul( unity_WorldToObject, float4( localIf94_g318 , 0.0 ) ).xyz;
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float Mode4_g315 = (float)_DoubleSidedNormalMode;
			float Cull4_g315 = (float)_CullMode;
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			float3 bump5_g315 = UnpackScaleNormal( tex2D( _BumpMap, uv_BumpMap ), _BumpScale );
			float3 Flip4_g315 = ( bump5_g315 * i.ASEVFace );
			float3 break7_g315 = bump5_g315;
			float3 appendResult11_g315 = (float3(break7_g315.x , break7_g315.y , ( break7_g315.z * i.ASEVFace )));
			float3 Mirror4_g315 = appendResult11_g315;
			float3 None4_g315 = bump5_g315;
			float3 localIf4_g315 = If4_g315( Mode4_g315 , Cull4_g315 , Flip4_g315 , Mirror4_g315 , None4_g315 );
			o.Normal = localIf4_g315;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode13 = tex2D( _MainTex, uv_MainTex );
			float4 Albedo101 = ( _Color * tex2DNode13 );
			float3 hsvTorgb19 = RGBToHSV( Albedo101.rgb );
			float3 hsvTorgb38 = HSVToRGB( float3(( hsvTorgb19 + ( ( i.vertexColor.g - 0.5 ) * _ColorVariation ) + _Hue ).x,( hsvTorgb19.y * _Saturation ),( hsvTorgb19.z * _Value )) );
			float4 color31_g302 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			float3 appendResult77_g302 = (float3(color31_g302.rgb));
			float temp_output_32_0_g302 = ( 1 * 2.0 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 normalizeResult11_g302 = normalize( ase_worldViewDir );
			float3 viewDir97_g302 = normalizeResult11_g302;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult12_g302 = normalize( ase_worldlightDir );
			float3 lightDir93_g302 = normalizeResult12_g302;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float dotResult23_g302 = dot( viewDir97_g302 , ( ( ( lightDir93_g302 + ase_worldNormal ) * _Distortion ) * -1.0 ) );
			float4 break38_g302 = Albedo101;
			float3 appendResult118_g302 = (float3(_TranslucentColor.rgb));
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 TranslucentCol119_g302 =  ( (float)_LightSouce - 0.0 > 0.0 ? appendResult118_g302 : (float)_LightSouce - 0.0 <= 0.0 && (float)_LightSouce + 0.0 >= 0.0 ? ase_lightColor.rgb : 0.0 ) ;
			float3 appendResult41_g302 = (float3(break38_g302.x , break38_g302.y , break38_g302.z));
			float dotResult50_g302 = dot( ase_worldNormal , lightDir93_g302 );
			float4 color69_g302 = IsGammaSpace() ? float4(0.5,0.5,0.5,1) : float4(0.2140411,0.2140411,0.2140411,1);
			float3 appendResult71_g302 = (float3(color69_g302.rgb));
			float3 normalizeResult46_g302 = normalize( ( lightDir93_g302 + viewDir97_g302 ) );
			float dotResult54_g302 = dot( ase_worldNormal , normalizeResult46_g302 );
			float perceptualSmoothness39 = _Glossiness;
			float3 geometricNormalWS39 = ase_worldNormal;
			float screenSpaceVariance39 = _GlossinessVariance;
			float threshold39 = _GlossinessThreshold;
			float localGetGeometricNormalVariance39 = GetGeometricNormalVariance( perceptualSmoothness39 , geometricNormalWS39 , screenSpaceVariance39 , threshold39 );
			float Smoothness50 = localGetGeometricNormalVariance39;
			float spec100_g302 = ( pow( max( 0.0 , dotResult54_g302 ) , ( 1.0 * 128.0 ) ) * Smoothness50 );
			float speca103_g302 = color69_g302.a;
			float4 appendResult75_g302 = (float4(( ( ( appendResult77_g302 * ( ( temp_output_32_0_g302 * ( pow( max( 0.0 , dotResult23_g302 ) , _Power ) * _Scale ) ) * break38_g302.w ) ) * ( TranslucentCol119_g302 * appendResult41_g302 ) ) + ( ( ( ( ( ( appendResult41_g302 * TranslucentCol119_g302 ) * max( 0.0 , dotResult50_g302 ) ) + TranslucentCol119_g302 ) * appendResult71_g302 ) * spec100_g302 ) * temp_output_32_0_g302 ) ) , ( ( ( ase_lightColor.a * speca103_g302 ) * spec100_g302 ) * 1 )));
			o.Albedo = ( float4( hsvTorgb38 , 0.0 ) + ( appendResult75_g302 * i.vertexColor.a * float4( hsvTorgb38 , 0.0 ) ) ).xyz;
			o.Metallic = _Metallic;
			o.Smoothness = Smoothness50;
			float lerpResult41 = lerp( 2.0 , i.vertexColor.a , _OcclusionStrength);
			float AO44 = lerpResult41;
			o.Occlusion = AO44;
			clip( tex2DNode13.a - _Cutoff);
			float AlphaMask46 = tex2DNode13.a;
			float temp_output_41_0_g319 = AlphaMask46;
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen45_g319 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither45_g319 = Dither8x8Bayer( fmod(clipScreen45_g319.x, 8), fmod(clipScreen45_g319.y, 8) );
			dither45_g319 = step( dither45_g319, unity_LODFade.x );
			#ifdef LOD_FADE_CROSSFADE
				float staticSwitch40_g319 = ( temp_output_41_0_g319 * dither45_g319 );
			#else
				float staticSwitch40_g319 = temp_output_41_0_g319;
			#endif
			o.Alpha = staticSwitch40_g319;
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=17600
94;330;1343;379;674.5753;29.58846;1.029317;True;False
Node;AmplifyShaderEditor.CommentaryNode;1;-3062.745,-1123.287;Inherit;False;1122.39;558.947;Albedo;9;51;46;32;30;14;13;11;10;101;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;10;-3026.142,-860.064;Float;True;Property;_MainTex;Albedo;6;0;Create;False;0;0;False;1;;None;8b0017825887ee44e83ac0cb49ceadf0;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;13;-2797.785,-859.193;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;11;-2711.997,-1039.753;Inherit;False;Property;_Color;Color;3;0;Create;True;0;0;False;1;Header(Albedo Texture);1,1,1,1;0.9174442,1,0.8382353,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;4;-3009.102,388.5925;Inherit;False;1068.058;483.6455;Comment;6;50;39;29;26;25;23;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;2;-1840.551,-1121.044;Inherit;False;1493.488;954.6044;Color Settings;17;54;49;38;27;28;22;19;21;17;20;18;15;16;12;102;216;217;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-2370.901,-878.1384;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-2194.34,-854.3077;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;12;-1770.079,-1006.449;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;29;-2874.704,532.0186;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;25;-2953.37,773.2766;Float;False;Property;_GlossinessThreshold;Smoothness Threshold;19;0;Create;False;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2963.272,448.2056;Inherit;False;Property;_Glossiness;Smoothness;17;0;Create;False;0;0;False;1;Header(Smoothness);0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-2959.102,678.6366;Float;False;Property;_GlossinessVariance;Smoothness Variance;18;0;Create;False;0;0;False;0;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;16;-1422.356,-1045.862;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;39;-2604.582,581.5456;Float;False;#define PerceptualSmoothnessToRoughness(perceptualSmoothness) (1.0 - perceptualSmoothness) * (1.0 - perceptualSmoothness)$#define RoughnessToPerceptualSmoothness(roughness) 1.0 - sqrt(roughness)$float3 deltaU = ddx(geometricNormalWS)@$float3 deltaV = ddy(geometricNormalWS)@$float variance = screenSpaceVariance * (dot(deltaU, deltaU) + dot(deltaV, deltaV))@$float roughness = PerceptualSmoothnessToRoughness(perceptualSmoothness)@$// Ref: Geometry into Shading - http://graphics.pixar.com/library/BumpRoughness/paper.pdf - equation (3)$float squaredRoughness = saturate(roughness * roughness + min(2.0 * variance, threshold * threshold))@ // threshold can be really low, square the value for easier$return RoughnessToPerceptualSmoothness(sqrt(squaredRoughness))@;1;False;4;True;perceptualSmoothness;FLOAT;0;In;;Float;False;True;geometricNormalWS;FLOAT3;0,0,0;In;;Float;False;True;screenSpaceVariance;FLOAT;0.5;In;;Float;False;True;threshold;FLOAT;0.5;In;;Float;False;GetGeometricNormalVariance;False;True;0;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0.5;False;3;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1549.556,-948.7612;Float;False;Property;_ColorVariation;Color Variation;16;0;Create;True;0;0;False;0;0.15;0.15;0;0.3;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-1713.34,-782.3077;Inherit;False;101;Albedo;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;3;-3004.281,904.856;Inherit;False;789.6466;355.3238;AO;4;44;41;31;24;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;5;-1839.721,-142.752;Inherit;False;1493.222;463.5325;Normals;5;53;48;108;47;37;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1531.751,-548.0708;Float;False;Property;_Value;Value;14;0;Create;True;0;0;False;0;1;1;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-1546.12,-862.4572;Half;False;Property;_Hue;Hue;13;0;Create;True;0;0;False;1;Header(Color Settings);0;0;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1533.596,-629.1736;Float;False;Property;_Saturation;Saturation;15;0;Create;True;0;0;False;0;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-1245.357,-961.9563;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;19;-1486.634,-778.3936;Float;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;50;-2279.743,581.3916;Inherit;False;Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2775.99,-663.3857;Half;False;Property;_Cutoff;Cutoff;10;0;Create;True;0;0;False;0;0.5;0.422;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-1093.254,-635.1566;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-1089.186,-860.0214;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1097.384,-729.265;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2954.281,1136.496;Half;False;Property;_OcclusionStrength;AO strength;20;0;Create;False;0;0;False;1;Header(Other Settings);0.6;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;217;-1352.064,-387.8107;Inherit;False;50;Smoothness;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;31;-2970.915,952.8558;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;216;-1329.064,-459.8107;Inherit;False;101;Albedo;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClipNode;32;-2409.253,-710.3296;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;37;-1789.721,-88.45222;Float;True;Property;_BumpMap;Normal Map;11;0;Create;False;0;0;False;1;Header(Normal Texture);None;bdcffb5968b084b4490b00efe97041e3;True;bump;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.LerpOp;41;-2643.427,1097.343;Inherit;False;3;0;FLOAT;2;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;245;-1039.316,-454.6885;Inherit;False;Translucent;22;;302;31c572777d9de6b4a8b2748411bf4658;0;3;37;FLOAT4;0,0,0,0;False;62;FLOAT;1;False;58;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.HSVToRGBNode;38;-939.7856,-730.908;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;6;-1836.591,364.7846;Inherit;False;1235.482;529.9922;Wind;2;251;252;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;47;-1538.721,-62.45196;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;48;-1451.371,133.5333;Half;False;Property;_BumpScale;Normal Strength;12;0;Create;False;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-2163.651,-714.051;Inherit;False;AlphaMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;-2472.646,1095.948;Inherit;False;AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-695.2146,-573.8313;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;53;-1213.393,-62.87763;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;251;-1306.628,575.7671;Inherit;False;Mtree Wind Main;4;;316;7b8005d279c29b544bf7997a1d0d05d6;1,166,1;0;6;FLOAT3;0;FLOAT;151;FLOAT;148;FLOAT;147;FLOAT;146;FLOAT2;153
Node;AmplifyShaderEditor.GetLocalVarNode;8;-256.05,225.4026;Inherit;False;46;AlphaMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;108;-1128.812,130.5641;Inherit;False;Property;_CullMode;Cull Mode;7;1;[Enum];Create;True;3;Off;0;Front;1;Back;2;0;True;0;0;0;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-3030.017,-983.7396;Inherit;False;Constant;_MaskClipValue;Mask Clip Value;14;1;[HideInInspector];Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;246;-794.7278,-61.63486;Inherit;False;Double Sided Backface Switch;8;;315;243a51f22b364cf4eac05d94dacd3901;0;2;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;7;-244.451,151.0123;Inherit;False;44;AO;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;222;-269.3214,2.728832;Inherit;False;Property;_Metallic;Metallic;21;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;253;-74.48341,196.8613;Inherit;False;LOD CrossFade;-1;;319;04f063bd39e5c7349bef37691158654e;1,44,1;1;41;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;9;-269.6682,77.80556;Inherit;False;50;Smoothness;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;54;-524.5686,-623.2985;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;252;-1048.929,563.9968;Inherit;False;Mtree Wind Leaves;0;;318;0f134f99adfaa05479348e0e95007b7c;0;6;56;FLOAT3;0,0,0;False;108;FLOAT;0;False;9;FLOAT;0;False;77;FLOAT;0;False;2;FLOAT;0;False;86;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;213;106.1244,-74.85284;Float;False;True;-1;2;;0;0;Standard;Mtree/Leaves;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.422;True;True;0;True;TransparentCutout;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;-1;-1;-1;0;False;0;0;True;108;-1;0;True;51;3;Pragma;instancing_options procedural:setup;False;;Custom;Pragma;multi_compile GPU_FRUSTUM_ON __;False;;Custom;Include;VS_indirect.cginc;False;a6d16d0571c954c4bbcc7edb6344bb7c;Custom;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;13;0;10;0
WireConnection;14;0;11;0
WireConnection;14;1;13;0
WireConnection;101;0;14;0
WireConnection;16;0;12;2
WireConnection;39;0;26;0
WireConnection;39;1;29;0
WireConnection;39;2;23;0
WireConnection;39;3;25;0
WireConnection;21;0;16;0
WireConnection;21;1;15;0
WireConnection;19;0;102;0
WireConnection;50;0;39;0
WireConnection;22;0;19;3
WireConnection;22;1;17;0
WireConnection;28;0;19;0
WireConnection;28;1;21;0
WireConnection;28;2;20;0
WireConnection;27;0;19;2
WireConnection;27;1;18;0
WireConnection;32;0;13;4
WireConnection;32;1;13;4
WireConnection;32;2;30;0
WireConnection;41;1;31;4
WireConnection;41;2;24;0
WireConnection;245;37;216;0
WireConnection;245;62;217;0
WireConnection;38;0;28;0
WireConnection;38;1;27;0
WireConnection;38;2;22;0
WireConnection;47;0;37;0
WireConnection;46;0;32;0
WireConnection;44;0;41;0
WireConnection;49;0;245;0
WireConnection;49;1;12;4
WireConnection;49;2;38;0
WireConnection;53;0;47;0
WireConnection;53;1;48;0
WireConnection;246;1;53;0
WireConnection;246;2;108;0
WireConnection;253;41;8;0
WireConnection;54;0;38;0
WireConnection;54;1;49;0
WireConnection;252;56;251;0
WireConnection;252;108;251;151
WireConnection;252;9;251;148
WireConnection;252;77;251;147
WireConnection;252;2;251;146
WireConnection;252;86;251;153
WireConnection;213;0;54;0
WireConnection;213;1;246;0
WireConnection;213;3;222;0
WireConnection;213;4;9;0
WireConnection;213;5;7;0
WireConnection;213;9;253;0
WireConnection;213;11;252;0
ASEEND*/
//CHKSM=C8DC51DBC8F8990154B7DB321A7F8AC4656A6602