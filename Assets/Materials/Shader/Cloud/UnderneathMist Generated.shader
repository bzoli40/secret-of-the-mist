Shader "Underneath Mist"
{
    Properties
    {
        _Rotate("Rotate", Vector) = (1, 0, 0, 0)
        _Noise_Scale("Noise Scale", Float) = 10
        _Cloud_Speed("Cloud Speed", Float) = 0.2
        _Cloud_Height("Cloud Height", Float) = 0
        _Noise_Remap("Noise Remap", Vector) = (0, 1, -1, 1)
        _Color_Peak("Color Peak", Color) = (1, 1, 1, 1)
        _Color_Valley("Color Valley", Color) = (0, 0, 0, 1)
        _Noise_Edge_1("Noise Edge 1", Float) = 0
        _Noise_Edge_2("Noise Edge 2", Float) = 1
        _Noise_Power("Noise Power", Float) = 1
        _Base_Scale("Base Scale", Float) = 10
        _Base_Speed("Base Speed", Float) = 0.1
        _Base_Strength("Base Strength", Float) = 1
        _Emission_Strength("Emission Strength", Float) = 1
        _Curveture_Radius("Curveture Radius", Float) = 0
        _Fresnel_Power("Fresnel Power", Float) = 1
        _Fresnel_Opacity("Fresnel Opacity", Float) = 1
        _Fade_Depth("Fade Depth", Float) = 1
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile _ _LIGHT_LAYERS
        #pragma multi_compile _ DEBUG_DISPLAY
        #pragma multi_compile _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float3 interp6 : INTERP6;
             float4 interp7 : INTERP7;
             float4 interp8 : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp5.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp8.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp4.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp8.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_Speed;
        float _Cloud_Height;
        float4 _Noise_Remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curveture_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2);
            float _Property_3f88e6c692054523ba9288de1067b329_Out_0 = _Curveture_Radius;
            float _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2;
            Unity_Divide_float(_Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2, _Property_3f88e6c692054523ba9288de1067b329_Out_0, _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2);
            float _Power_c99c9141abe44cc78950e229089c9c63_Out_2;
            Unity_Power_float(_Divide_092294afb6404e7883452a61ce4ebe8d_Out_2, 3, _Power_c99c9141abe44cc78950e229089c9c63_Out_2);
            float3 _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_c99c9141abe44cc78950e229089c9c63_Out_2.xxx), _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2);
            float _Property_2d6b9cde518e422a93f243169b594a66_Out_0 = _Cloud_Height;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float3 _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2);
            float3 _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2;
            Unity_Multiply_float3_float3((_Property_2d6b9cde518e422a93f243169b594a66_Out_0.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2);
            float3 _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2);
            float3 _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            Unity_Add_float3(_Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2, _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2);
            description.Position = _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_29db2a9e34314635b66e7c370e19649e_Out_0 = _Color_Valley;
            float4 _Property_da283fce167f4e29b3674417457a4b37_Out_0 = _Color_Peak;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float4 _Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3;
            Unity_Lerp_float4(_Property_29db2a9e34314635b66e7c370e19649e_Out_0, _Property_da283fce167f4e29b3674417457a4b37_Out_0, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxxx), _Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3);
            float _Property_bc54bebcb75440499e3fd27961fc84dd_Out_0 = _Fresnel_Power;
            float _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_bc54bebcb75440499e3fd27961fc84dd_Out_0, _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3);
            float _Multiply_0052c1359335410fbdc0153da3f0f220_Out_2;
            Unity_Multiply_float_float(_Divide_0b006a10ae5249c99f04ca020e507386_Out_2, _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3, _Multiply_0052c1359335410fbdc0153da3f0f220_Out_2);
            float _Property_28dca7ceb7d9484689ab1635c9d18323_Out_0 = _Fresnel_Opacity;
            float _Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2;
            Unity_Multiply_float_float(_Multiply_0052c1359335410fbdc0153da3f0f220_Out_2, _Property_28dca7ceb7d9484689ab1635c9d18323_Out_0, _Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2);
            float4 _Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2;
            Unity_Add_float4(_Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3, (_Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2.xxxx), _Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2);
            float _Property_e13193a3714e408dbc22e408b1cf4f2c_Out_0 = _Emission_Strength;
            float4 _Multiply_b753da97e85640a78b70fba480e2781a_Out_2;
            Unity_Multiply_float4_float4(_Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2, (_Property_e13193a3714e408dbc22e408b1cf4f2c_Out_0.xxxx), _Multiply_b753da97e85640a78b70fba480e2781a_Out_2);
            float _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1);
            float4 _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0 = IN.ScreenPosition;
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_R_1 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[0];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_G_2 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[1];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_B_3 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[2];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_A_4 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[3];
            float _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2;
            Unity_Subtract_float(_Split_238e81d3fd0540deb7ece8a5eccb881d_A_4, 1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2);
            float _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2;
            Unity_Subtract_float(_SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2, _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2);
            float _Property_f588d37070e348b2b8646885a56c14fa_Out_0 = _Fade_Depth;
            float _Divide_26748a8584884003be3a46068c1a9850_Out_2;
            Unity_Divide_float(_Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2, _Property_f588d37070e348b2b8646885a56c14fa_Out_0, _Divide_26748a8584884003be3a46068c1a9850_Out_2);
            float _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            Unity_Saturate_float(_Divide_26748a8584884003be3a46068c1a9850_Out_2, _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1);
            surface.BaseColor = (_Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_b753da97e85640a78b70fba480e2781a_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual

        //ZWrize Off
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile _ _LIGHT_LAYERS
        #pragma multi_compile _ _RENDER_PASS_ENABLED
        #pragma multi_compile _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float3 interp6 : INTERP6;
             float4 interp7 : INTERP7;
             float4 interp8 : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp5.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp8.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp4.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp8.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_Speed;
        float _Cloud_Height;
        float4 _Noise_Remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curveture_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2);
            float _Property_3f88e6c692054523ba9288de1067b329_Out_0 = _Curveture_Radius;
            float _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2;
            Unity_Divide_float(_Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2, _Property_3f88e6c692054523ba9288de1067b329_Out_0, _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2);
            float _Power_c99c9141abe44cc78950e229089c9c63_Out_2;
            Unity_Power_float(_Divide_092294afb6404e7883452a61ce4ebe8d_Out_2, 3, _Power_c99c9141abe44cc78950e229089c9c63_Out_2);
            float3 _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_c99c9141abe44cc78950e229089c9c63_Out_2.xxx), _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2);
            float _Property_2d6b9cde518e422a93f243169b594a66_Out_0 = _Cloud_Height;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float3 _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2);
            float3 _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2;
            Unity_Multiply_float3_float3((_Property_2d6b9cde518e422a93f243169b594a66_Out_0.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2);
            float3 _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2);
            float3 _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            Unity_Add_float3(_Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2, _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2);
            description.Position = _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_29db2a9e34314635b66e7c370e19649e_Out_0 = _Color_Valley;
            float4 _Property_da283fce167f4e29b3674417457a4b37_Out_0 = _Color_Peak;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float4 _Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3;
            Unity_Lerp_float4(_Property_29db2a9e34314635b66e7c370e19649e_Out_0, _Property_da283fce167f4e29b3674417457a4b37_Out_0, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxxx), _Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3);
            float _Property_bc54bebcb75440499e3fd27961fc84dd_Out_0 = _Fresnel_Power;
            float _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_bc54bebcb75440499e3fd27961fc84dd_Out_0, _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3);
            float _Multiply_0052c1359335410fbdc0153da3f0f220_Out_2;
            Unity_Multiply_float_float(_Divide_0b006a10ae5249c99f04ca020e507386_Out_2, _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3, _Multiply_0052c1359335410fbdc0153da3f0f220_Out_2);
            float _Property_28dca7ceb7d9484689ab1635c9d18323_Out_0 = _Fresnel_Opacity;
            float _Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2;
            Unity_Multiply_float_float(_Multiply_0052c1359335410fbdc0153da3f0f220_Out_2, _Property_28dca7ceb7d9484689ab1635c9d18323_Out_0, _Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2);
            float4 _Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2;
            Unity_Add_float4(_Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3, (_Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2.xxxx), _Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2);
            float _Property_e13193a3714e408dbc22e408b1cf4f2c_Out_0 = _Emission_Strength;
            float4 _Multiply_b753da97e85640a78b70fba480e2781a_Out_2;
            Unity_Multiply_float4_float4(_Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2, (_Property_e13193a3714e408dbc22e408b1cf4f2c_Out_0.xxxx), _Multiply_b753da97e85640a78b70fba480e2781a_Out_2);
            float _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1);
            float4 _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0 = IN.ScreenPosition;
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_R_1 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[0];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_G_2 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[1];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_B_3 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[2];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_A_4 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[3];
            float _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2;
            Unity_Subtract_float(_Split_238e81d3fd0540deb7ece8a5eccb881d_A_4, 1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2);
            float _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2;
            Unity_Subtract_float(_SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2, _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2);
            float _Property_f588d37070e348b2b8646885a56c14fa_Out_0 = _Fade_Depth;
            float _Divide_26748a8584884003be3a46068c1a9850_Out_2;
            Unity_Divide_float(_Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2, _Property_f588d37070e348b2b8646885a56c14fa_Out_0, _Divide_26748a8584884003be3a46068c1a9850_Out_2);
            float _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            Unity_Saturate_float(_Divide_26748a8584884003be3a46068c1a9850_Out_2, _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1);
            surface.BaseColor = (_Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_b753da97e85640a78b70fba480e2781a_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_Speed;
        float _Cloud_Height;
        float4 _Noise_Remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curveture_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2);
            float _Property_3f88e6c692054523ba9288de1067b329_Out_0 = _Curveture_Radius;
            float _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2;
            Unity_Divide_float(_Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2, _Property_3f88e6c692054523ba9288de1067b329_Out_0, _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2);
            float _Power_c99c9141abe44cc78950e229089c9c63_Out_2;
            Unity_Power_float(_Divide_092294afb6404e7883452a61ce4ebe8d_Out_2, 3, _Power_c99c9141abe44cc78950e229089c9c63_Out_2);
            float3 _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_c99c9141abe44cc78950e229089c9c63_Out_2.xxx), _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2);
            float _Property_2d6b9cde518e422a93f243169b594a66_Out_0 = _Cloud_Height;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float3 _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2);
            float3 _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2;
            Unity_Multiply_float3_float3((_Property_2d6b9cde518e422a93f243169b594a66_Out_0.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2);
            float3 _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2);
            float3 _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            Unity_Add_float3(_Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2, _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2);
            description.Position = _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1);
            float4 _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0 = IN.ScreenPosition;
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_R_1 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[0];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_G_2 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[1];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_B_3 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[2];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_A_4 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[3];
            float _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2;
            Unity_Subtract_float(_Split_238e81d3fd0540deb7ece8a5eccb881d_A_4, 1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2);
            float _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2;
            Unity_Subtract_float(_SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2, _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2);
            float _Property_f588d37070e348b2b8646885a56c14fa_Out_0 = _Fade_Depth;
            float _Divide_26748a8584884003be3a46068c1a9850_Out_2;
            Unity_Divide_float(_Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2, _Property_f588d37070e348b2b8646885a56c14fa_Out_0, _Divide_26748a8584884003be3a46068c1a9850_Out_2);
            float _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            Unity_Saturate_float(_Divide_26748a8584884003be3a46068c1a9850_Out_2, _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1);
            surface.Alpha = _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_Speed;
        float _Cloud_Height;
        float4 _Noise_Remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curveture_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2);
            float _Property_3f88e6c692054523ba9288de1067b329_Out_0 = _Curveture_Radius;
            float _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2;
            Unity_Divide_float(_Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2, _Property_3f88e6c692054523ba9288de1067b329_Out_0, _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2);
            float _Power_c99c9141abe44cc78950e229089c9c63_Out_2;
            Unity_Power_float(_Divide_092294afb6404e7883452a61ce4ebe8d_Out_2, 3, _Power_c99c9141abe44cc78950e229089c9c63_Out_2);
            float3 _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_c99c9141abe44cc78950e229089c9c63_Out_2.xxx), _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2);
            float _Property_2d6b9cde518e422a93f243169b594a66_Out_0 = _Cloud_Height;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float3 _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2);
            float3 _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2;
            Unity_Multiply_float3_float3((_Property_2d6b9cde518e422a93f243169b594a66_Out_0.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2);
            float3 _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2);
            float3 _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            Unity_Add_float3(_Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2, _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2);
            description.Position = _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1);
            float4 _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0 = IN.ScreenPosition;
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_R_1 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[0];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_G_2 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[1];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_B_3 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[2];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_A_4 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[3];
            float _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2;
            Unity_Subtract_float(_Split_238e81d3fd0540deb7ece8a5eccb881d_A_4, 1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2);
            float _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2;
            Unity_Subtract_float(_SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2, _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2);
            float _Property_f588d37070e348b2b8646885a56c14fa_Out_0 = _Fade_Depth;
            float _Divide_26748a8584884003be3a46068c1a9850_Out_2;
            Unity_Divide_float(_Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2, _Property_f588d37070e348b2b8646885a56c14fa_Out_0, _Divide_26748a8584884003be3a46068c1a9850_Out_2);
            float _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            Unity_Saturate_float(_Divide_26748a8584884003be3a46068c1a9850_Out_2, _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
             float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float4 interp4 : INTERP4;
             float3 interp5 : INTERP5;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.texCoord0;
            output.interp3.xyzw =  input.texCoord1;
            output.interp4.xyzw =  input.texCoord2;
            output.interp5.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.texCoord0 = input.interp2.xyzw;
            output.texCoord1 = input.interp3.xyzw;
            output.texCoord2 = input.interp4.xyzw;
            output.viewDirectionWS = input.interp5.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_Speed;
        float _Cloud_Height;
        float4 _Noise_Remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curveture_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2);
            float _Property_3f88e6c692054523ba9288de1067b329_Out_0 = _Curveture_Radius;
            float _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2;
            Unity_Divide_float(_Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2, _Property_3f88e6c692054523ba9288de1067b329_Out_0, _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2);
            float _Power_c99c9141abe44cc78950e229089c9c63_Out_2;
            Unity_Power_float(_Divide_092294afb6404e7883452a61ce4ebe8d_Out_2, 3, _Power_c99c9141abe44cc78950e229089c9c63_Out_2);
            float3 _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_c99c9141abe44cc78950e229089c9c63_Out_2.xxx), _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2);
            float _Property_2d6b9cde518e422a93f243169b594a66_Out_0 = _Cloud_Height;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float3 _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2);
            float3 _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2;
            Unity_Multiply_float3_float3((_Property_2d6b9cde518e422a93f243169b594a66_Out_0.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2);
            float3 _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2);
            float3 _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            Unity_Add_float3(_Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2, _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2);
            description.Position = _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_29db2a9e34314635b66e7c370e19649e_Out_0 = _Color_Valley;
            float4 _Property_da283fce167f4e29b3674417457a4b37_Out_0 = _Color_Peak;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float4 _Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3;
            Unity_Lerp_float4(_Property_29db2a9e34314635b66e7c370e19649e_Out_0, _Property_da283fce167f4e29b3674417457a4b37_Out_0, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxxx), _Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3);
            float _Property_bc54bebcb75440499e3fd27961fc84dd_Out_0 = _Fresnel_Power;
            float _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_bc54bebcb75440499e3fd27961fc84dd_Out_0, _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3);
            float _Multiply_0052c1359335410fbdc0153da3f0f220_Out_2;
            Unity_Multiply_float_float(_Divide_0b006a10ae5249c99f04ca020e507386_Out_2, _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3, _Multiply_0052c1359335410fbdc0153da3f0f220_Out_2);
            float _Property_28dca7ceb7d9484689ab1635c9d18323_Out_0 = _Fresnel_Opacity;
            float _Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2;
            Unity_Multiply_float_float(_Multiply_0052c1359335410fbdc0153da3f0f220_Out_2, _Property_28dca7ceb7d9484689ab1635c9d18323_Out_0, _Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2);
            float4 _Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2;
            Unity_Add_float4(_Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3, (_Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2.xxxx), _Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2);
            float _Property_e13193a3714e408dbc22e408b1cf4f2c_Out_0 = _Emission_Strength;
            float4 _Multiply_b753da97e85640a78b70fba480e2781a_Out_2;
            Unity_Multiply_float4_float4(_Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2, (_Property_e13193a3714e408dbc22e408b1cf4f2c_Out_0.xxxx), _Multiply_b753da97e85640a78b70fba480e2781a_Out_2);
            float _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1);
            float4 _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0 = IN.ScreenPosition;
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_R_1 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[0];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_G_2 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[1];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_B_3 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[2];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_A_4 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[3];
            float _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2;
            Unity_Subtract_float(_Split_238e81d3fd0540deb7ece8a5eccb881d_A_4, 1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2);
            float _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2;
            Unity_Subtract_float(_SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2, _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2);
            float _Property_f588d37070e348b2b8646885a56c14fa_Out_0 = _Fade_Depth;
            float _Divide_26748a8584884003be3a46068c1a9850_Out_2;
            Unity_Divide_float(_Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2, _Property_f588d37070e348b2b8646885a56c14fa_Out_0, _Divide_26748a8584884003be3a46068c1a9850_Out_2);
            float _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            Unity_Saturate_float(_Divide_26748a8584884003be3a46068c1a9850_Out_2, _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1);
            surface.BaseColor = (_Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2.xyz);
            surface.Emission = (_Multiply_b753da97e85640a78b70fba480e2781a_Out_2.xyz);
            surface.Alpha = _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_Speed;
        float _Cloud_Height;
        float4 _Noise_Remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curveture_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2);
            float _Property_3f88e6c692054523ba9288de1067b329_Out_0 = _Curveture_Radius;
            float _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2;
            Unity_Divide_float(_Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2, _Property_3f88e6c692054523ba9288de1067b329_Out_0, _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2);
            float _Power_c99c9141abe44cc78950e229089c9c63_Out_2;
            Unity_Power_float(_Divide_092294afb6404e7883452a61ce4ebe8d_Out_2, 3, _Power_c99c9141abe44cc78950e229089c9c63_Out_2);
            float3 _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_c99c9141abe44cc78950e229089c9c63_Out_2.xxx), _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2);
            float _Property_2d6b9cde518e422a93f243169b594a66_Out_0 = _Cloud_Height;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float3 _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2);
            float3 _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2;
            Unity_Multiply_float3_float3((_Property_2d6b9cde518e422a93f243169b594a66_Out_0.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2);
            float3 _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2);
            float3 _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            Unity_Add_float3(_Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2, _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2);
            description.Position = _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1);
            float4 _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0 = IN.ScreenPosition;
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_R_1 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[0];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_G_2 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[1];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_B_3 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[2];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_A_4 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[3];
            float _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2;
            Unity_Subtract_float(_Split_238e81d3fd0540deb7ece8a5eccb881d_A_4, 1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2);
            float _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2;
            Unity_Subtract_float(_SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2, _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2);
            float _Property_f588d37070e348b2b8646885a56c14fa_Out_0 = _Fade_Depth;
            float _Divide_26748a8584884003be3a46068c1a9850_Out_2;
            Unity_Divide_float(_Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2, _Property_f588d37070e348b2b8646885a56c14fa_Out_0, _Divide_26748a8584884003be3a46068c1a9850_Out_2);
            float _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            Unity_Saturate_float(_Divide_26748a8584884003be3a46068c1a9850_Out_2, _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1);
            surface.Alpha = _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_Speed;
        float _Cloud_Height;
        float4 _Noise_Remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curveture_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2);
            float _Property_3f88e6c692054523ba9288de1067b329_Out_0 = _Curveture_Radius;
            float _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2;
            Unity_Divide_float(_Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2, _Property_3f88e6c692054523ba9288de1067b329_Out_0, _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2);
            float _Power_c99c9141abe44cc78950e229089c9c63_Out_2;
            Unity_Power_float(_Divide_092294afb6404e7883452a61ce4ebe8d_Out_2, 3, _Power_c99c9141abe44cc78950e229089c9c63_Out_2);
            float3 _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_c99c9141abe44cc78950e229089c9c63_Out_2.xxx), _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2);
            float _Property_2d6b9cde518e422a93f243169b594a66_Out_0 = _Cloud_Height;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float3 _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2);
            float3 _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2;
            Unity_Multiply_float3_float3((_Property_2d6b9cde518e422a93f243169b594a66_Out_0.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2);
            float3 _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2);
            float3 _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            Unity_Add_float3(_Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2, _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2);
            description.Position = _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1);
            float4 _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0 = IN.ScreenPosition;
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_R_1 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[0];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_G_2 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[1];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_B_3 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[2];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_A_4 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[3];
            float _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2;
            Unity_Subtract_float(_Split_238e81d3fd0540deb7ece8a5eccb881d_A_4, 1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2);
            float _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2;
            Unity_Subtract_float(_SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2, _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2);
            float _Property_f588d37070e348b2b8646885a56c14fa_Out_0 = _Fade_Depth;
            float _Divide_26748a8584884003be3a46068c1a9850_Out_2;
            Unity_Divide_float(_Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2, _Property_f588d37070e348b2b8646885a56c14fa_Out_0, _Divide_26748a8584884003be3a46068c1a9850_Out_2);
            float _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            Unity_Saturate_float(_Divide_26748a8584884003be3a46068c1a9850_Out_2, _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1);
            surface.Alpha = _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float3 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.viewDirectionWS = input.interp2.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_Speed;
        float _Cloud_Height;
        float4 _Noise_Remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curveture_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2);
            float _Property_3f88e6c692054523ba9288de1067b329_Out_0 = _Curveture_Radius;
            float _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2;
            Unity_Divide_float(_Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2, _Property_3f88e6c692054523ba9288de1067b329_Out_0, _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2);
            float _Power_c99c9141abe44cc78950e229089c9c63_Out_2;
            Unity_Power_float(_Divide_092294afb6404e7883452a61ce4ebe8d_Out_2, 3, _Power_c99c9141abe44cc78950e229089c9c63_Out_2);
            float3 _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_c99c9141abe44cc78950e229089c9c63_Out_2.xxx), _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2);
            float _Property_2d6b9cde518e422a93f243169b594a66_Out_0 = _Cloud_Height;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float3 _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2);
            float3 _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2;
            Unity_Multiply_float3_float3((_Property_2d6b9cde518e422a93f243169b594a66_Out_0.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2);
            float3 _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2);
            float3 _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            Unity_Add_float3(_Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2, _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2);
            description.Position = _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_29db2a9e34314635b66e7c370e19649e_Out_0 = _Color_Valley;
            float4 _Property_da283fce167f4e29b3674417457a4b37_Out_0 = _Color_Peak;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float4 _Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3;
            Unity_Lerp_float4(_Property_29db2a9e34314635b66e7c370e19649e_Out_0, _Property_da283fce167f4e29b3674417457a4b37_Out_0, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxxx), _Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3);
            float _Property_bc54bebcb75440499e3fd27961fc84dd_Out_0 = _Fresnel_Power;
            float _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_bc54bebcb75440499e3fd27961fc84dd_Out_0, _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3);
            float _Multiply_0052c1359335410fbdc0153da3f0f220_Out_2;
            Unity_Multiply_float_float(_Divide_0b006a10ae5249c99f04ca020e507386_Out_2, _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3, _Multiply_0052c1359335410fbdc0153da3f0f220_Out_2);
            float _Property_28dca7ceb7d9484689ab1635c9d18323_Out_0 = _Fresnel_Opacity;
            float _Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2;
            Unity_Multiply_float_float(_Multiply_0052c1359335410fbdc0153da3f0f220_Out_2, _Property_28dca7ceb7d9484689ab1635c9d18323_Out_0, _Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2);
            float4 _Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2;
            Unity_Add_float4(_Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3, (_Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2.xxxx), _Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2);
            float _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1);
            float4 _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0 = IN.ScreenPosition;
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_R_1 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[0];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_G_2 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[1];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_B_3 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[2];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_A_4 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[3];
            float _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2;
            Unity_Subtract_float(_Split_238e81d3fd0540deb7ece8a5eccb881d_A_4, 1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2);
            float _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2;
            Unity_Subtract_float(_SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2, _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2);
            float _Property_f588d37070e348b2b8646885a56c14fa_Out_0 = _Fade_Depth;
            float _Divide_26748a8584884003be3a46068c1a9850_Out_2;
            Unity_Divide_float(_Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2, _Property_f588d37070e348b2b8646885a56c14fa_Out_0, _Divide_26748a8584884003be3a46068c1a9850_Out_2);
            float _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            Unity_Saturate_float(_Divide_26748a8584884003be3a46068c1a9850_Out_2, _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1);
            surface.BaseColor = (_Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2.xyz);
            surface.Alpha = _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile _ _LIGHT_LAYERS
        #pragma multi_compile _ DEBUG_DISPLAY
        #pragma multi_compile _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float3 interp6 : INTERP6;
             float4 interp7 : INTERP7;
             float4 interp8 : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp5.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp8.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp4.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp8.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_Speed;
        float _Cloud_Height;
        float4 _Noise_Remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curveture_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2);
            float _Property_3f88e6c692054523ba9288de1067b329_Out_0 = _Curveture_Radius;
            float _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2;
            Unity_Divide_float(_Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2, _Property_3f88e6c692054523ba9288de1067b329_Out_0, _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2);
            float _Power_c99c9141abe44cc78950e229089c9c63_Out_2;
            Unity_Power_float(_Divide_092294afb6404e7883452a61ce4ebe8d_Out_2, 3, _Power_c99c9141abe44cc78950e229089c9c63_Out_2);
            float3 _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_c99c9141abe44cc78950e229089c9c63_Out_2.xxx), _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2);
            float _Property_2d6b9cde518e422a93f243169b594a66_Out_0 = _Cloud_Height;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float3 _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2);
            float3 _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2;
            Unity_Multiply_float3_float3((_Property_2d6b9cde518e422a93f243169b594a66_Out_0.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2);
            float3 _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2);
            float3 _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            Unity_Add_float3(_Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2, _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2);
            description.Position = _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_29db2a9e34314635b66e7c370e19649e_Out_0 = _Color_Valley;
            float4 _Property_da283fce167f4e29b3674417457a4b37_Out_0 = _Color_Peak;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float4 _Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3;
            Unity_Lerp_float4(_Property_29db2a9e34314635b66e7c370e19649e_Out_0, _Property_da283fce167f4e29b3674417457a4b37_Out_0, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxxx), _Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3);
            float _Property_bc54bebcb75440499e3fd27961fc84dd_Out_0 = _Fresnel_Power;
            float _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_bc54bebcb75440499e3fd27961fc84dd_Out_0, _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3);
            float _Multiply_0052c1359335410fbdc0153da3f0f220_Out_2;
            Unity_Multiply_float_float(_Divide_0b006a10ae5249c99f04ca020e507386_Out_2, _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3, _Multiply_0052c1359335410fbdc0153da3f0f220_Out_2);
            float _Property_28dca7ceb7d9484689ab1635c9d18323_Out_0 = _Fresnel_Opacity;
            float _Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2;
            Unity_Multiply_float_float(_Multiply_0052c1359335410fbdc0153da3f0f220_Out_2, _Property_28dca7ceb7d9484689ab1635c9d18323_Out_0, _Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2);
            float4 _Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2;
            Unity_Add_float4(_Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3, (_Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2.xxxx), _Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2);
            float _Property_e13193a3714e408dbc22e408b1cf4f2c_Out_0 = _Emission_Strength;
            float4 _Multiply_b753da97e85640a78b70fba480e2781a_Out_2;
            Unity_Multiply_float4_float4(_Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2, (_Property_e13193a3714e408dbc22e408b1cf4f2c_Out_0.xxxx), _Multiply_b753da97e85640a78b70fba480e2781a_Out_2);
            float _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1);
            float4 _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0 = IN.ScreenPosition;
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_R_1 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[0];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_G_2 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[1];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_B_3 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[2];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_A_4 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[3];
            float _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2;
            Unity_Subtract_float(_Split_238e81d3fd0540deb7ece8a5eccb881d_A_4, 1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2);
            float _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2;
            Unity_Subtract_float(_SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2, _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2);
            float _Property_f588d37070e348b2b8646885a56c14fa_Out_0 = _Fade_Depth;
            float _Divide_26748a8584884003be3a46068c1a9850_Out_2;
            Unity_Divide_float(_Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2, _Property_f588d37070e348b2b8646885a56c14fa_Out_0, _Divide_26748a8584884003be3a46068c1a9850_Out_2);
            float _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            Unity_Saturate_float(_Divide_26748a8584884003be3a46068c1a9850_Out_2, _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1);
            surface.BaseColor = (_Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_b753da97e85640a78b70fba480e2781a_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_Speed;
        float _Cloud_Height;
        float4 _Noise_Remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curveture_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2);
            float _Property_3f88e6c692054523ba9288de1067b329_Out_0 = _Curveture_Radius;
            float _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2;
            Unity_Divide_float(_Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2, _Property_3f88e6c692054523ba9288de1067b329_Out_0, _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2);
            float _Power_c99c9141abe44cc78950e229089c9c63_Out_2;
            Unity_Power_float(_Divide_092294afb6404e7883452a61ce4ebe8d_Out_2, 3, _Power_c99c9141abe44cc78950e229089c9c63_Out_2);
            float3 _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_c99c9141abe44cc78950e229089c9c63_Out_2.xxx), _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2);
            float _Property_2d6b9cde518e422a93f243169b594a66_Out_0 = _Cloud_Height;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float3 _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2);
            float3 _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2;
            Unity_Multiply_float3_float3((_Property_2d6b9cde518e422a93f243169b594a66_Out_0.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2);
            float3 _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2);
            float3 _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            Unity_Add_float3(_Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2, _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2);
            description.Position = _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1);
            float4 _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0 = IN.ScreenPosition;
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_R_1 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[0];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_G_2 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[1];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_B_3 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[2];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_A_4 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[3];
            float _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2;
            Unity_Subtract_float(_Split_238e81d3fd0540deb7ece8a5eccb881d_A_4, 1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2);
            float _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2;
            Unity_Subtract_float(_SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2, _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2);
            float _Property_f588d37070e348b2b8646885a56c14fa_Out_0 = _Fade_Depth;
            float _Divide_26748a8584884003be3a46068c1a9850_Out_2;
            Unity_Divide_float(_Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2, _Property_f588d37070e348b2b8646885a56c14fa_Out_0, _Divide_26748a8584884003be3a46068c1a9850_Out_2);
            float _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            Unity_Saturate_float(_Divide_26748a8584884003be3a46068c1a9850_Out_2, _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1);
            surface.Alpha = _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_Speed;
        float _Cloud_Height;
        float4 _Noise_Remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curveture_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2);
            float _Property_3f88e6c692054523ba9288de1067b329_Out_0 = _Curveture_Radius;
            float _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2;
            Unity_Divide_float(_Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2, _Property_3f88e6c692054523ba9288de1067b329_Out_0, _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2);
            float _Power_c99c9141abe44cc78950e229089c9c63_Out_2;
            Unity_Power_float(_Divide_092294afb6404e7883452a61ce4ebe8d_Out_2, 3, _Power_c99c9141abe44cc78950e229089c9c63_Out_2);
            float3 _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_c99c9141abe44cc78950e229089c9c63_Out_2.xxx), _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2);
            float _Property_2d6b9cde518e422a93f243169b594a66_Out_0 = _Cloud_Height;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float3 _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2);
            float3 _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2;
            Unity_Multiply_float3_float3((_Property_2d6b9cde518e422a93f243169b594a66_Out_0.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2);
            float3 _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2);
            float3 _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            Unity_Add_float3(_Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2, _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2);
            description.Position = _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1);
            float4 _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0 = IN.ScreenPosition;
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_R_1 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[0];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_G_2 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[1];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_B_3 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[2];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_A_4 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[3];
            float _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2;
            Unity_Subtract_float(_Split_238e81d3fd0540deb7ece8a5eccb881d_A_4, 1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2);
            float _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2;
            Unity_Subtract_float(_SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2, _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2);
            float _Property_f588d37070e348b2b8646885a56c14fa_Out_0 = _Fade_Depth;
            float _Divide_26748a8584884003be3a46068c1a9850_Out_2;
            Unity_Divide_float(_Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2, _Property_f588d37070e348b2b8646885a56c14fa_Out_0, _Divide_26748a8584884003be3a46068c1a9850_Out_2);
            float _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            Unity_Saturate_float(_Divide_26748a8584884003be3a46068c1a9850_Out_2, _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
             float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float4 interp4 : INTERP4;
             float3 interp5 : INTERP5;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.texCoord0;
            output.interp3.xyzw =  input.texCoord1;
            output.interp4.xyzw =  input.texCoord2;
            output.interp5.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.texCoord0 = input.interp2.xyzw;
            output.texCoord1 = input.interp3.xyzw;
            output.texCoord2 = input.interp4.xyzw;
            output.viewDirectionWS = input.interp5.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_Speed;
        float _Cloud_Height;
        float4 _Noise_Remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curveture_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2);
            float _Property_3f88e6c692054523ba9288de1067b329_Out_0 = _Curveture_Radius;
            float _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2;
            Unity_Divide_float(_Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2, _Property_3f88e6c692054523ba9288de1067b329_Out_0, _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2);
            float _Power_c99c9141abe44cc78950e229089c9c63_Out_2;
            Unity_Power_float(_Divide_092294afb6404e7883452a61ce4ebe8d_Out_2, 3, _Power_c99c9141abe44cc78950e229089c9c63_Out_2);
            float3 _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_c99c9141abe44cc78950e229089c9c63_Out_2.xxx), _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2);
            float _Property_2d6b9cde518e422a93f243169b594a66_Out_0 = _Cloud_Height;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float3 _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2);
            float3 _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2;
            Unity_Multiply_float3_float3((_Property_2d6b9cde518e422a93f243169b594a66_Out_0.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2);
            float3 _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2);
            float3 _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            Unity_Add_float3(_Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2, _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2);
            description.Position = _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_29db2a9e34314635b66e7c370e19649e_Out_0 = _Color_Valley;
            float4 _Property_da283fce167f4e29b3674417457a4b37_Out_0 = _Color_Peak;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float4 _Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3;
            Unity_Lerp_float4(_Property_29db2a9e34314635b66e7c370e19649e_Out_0, _Property_da283fce167f4e29b3674417457a4b37_Out_0, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxxx), _Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3);
            float _Property_bc54bebcb75440499e3fd27961fc84dd_Out_0 = _Fresnel_Power;
            float _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_bc54bebcb75440499e3fd27961fc84dd_Out_0, _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3);
            float _Multiply_0052c1359335410fbdc0153da3f0f220_Out_2;
            Unity_Multiply_float_float(_Divide_0b006a10ae5249c99f04ca020e507386_Out_2, _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3, _Multiply_0052c1359335410fbdc0153da3f0f220_Out_2);
            float _Property_28dca7ceb7d9484689ab1635c9d18323_Out_0 = _Fresnel_Opacity;
            float _Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2;
            Unity_Multiply_float_float(_Multiply_0052c1359335410fbdc0153da3f0f220_Out_2, _Property_28dca7ceb7d9484689ab1635c9d18323_Out_0, _Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2);
            float4 _Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2;
            Unity_Add_float4(_Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3, (_Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2.xxxx), _Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2);
            float _Property_e13193a3714e408dbc22e408b1cf4f2c_Out_0 = _Emission_Strength;
            float4 _Multiply_b753da97e85640a78b70fba480e2781a_Out_2;
            Unity_Multiply_float4_float4(_Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2, (_Property_e13193a3714e408dbc22e408b1cf4f2c_Out_0.xxxx), _Multiply_b753da97e85640a78b70fba480e2781a_Out_2);
            float _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1);
            float4 _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0 = IN.ScreenPosition;
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_R_1 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[0];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_G_2 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[1];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_B_3 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[2];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_A_4 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[3];
            float _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2;
            Unity_Subtract_float(_Split_238e81d3fd0540deb7ece8a5eccb881d_A_4, 1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2);
            float _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2;
            Unity_Subtract_float(_SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2, _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2);
            float _Property_f588d37070e348b2b8646885a56c14fa_Out_0 = _Fade_Depth;
            float _Divide_26748a8584884003be3a46068c1a9850_Out_2;
            Unity_Divide_float(_Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2, _Property_f588d37070e348b2b8646885a56c14fa_Out_0, _Divide_26748a8584884003be3a46068c1a9850_Out_2);
            float _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            Unity_Saturate_float(_Divide_26748a8584884003be3a46068c1a9850_Out_2, _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1);
            surface.BaseColor = (_Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2.xyz);
            surface.Emission = (_Multiply_b753da97e85640a78b70fba480e2781a_Out_2.xyz);
            surface.Alpha = _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_Speed;
        float _Cloud_Height;
        float4 _Noise_Remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curveture_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2);
            float _Property_3f88e6c692054523ba9288de1067b329_Out_0 = _Curveture_Radius;
            float _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2;
            Unity_Divide_float(_Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2, _Property_3f88e6c692054523ba9288de1067b329_Out_0, _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2);
            float _Power_c99c9141abe44cc78950e229089c9c63_Out_2;
            Unity_Power_float(_Divide_092294afb6404e7883452a61ce4ebe8d_Out_2, 3, _Power_c99c9141abe44cc78950e229089c9c63_Out_2);
            float3 _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_c99c9141abe44cc78950e229089c9c63_Out_2.xxx), _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2);
            float _Property_2d6b9cde518e422a93f243169b594a66_Out_0 = _Cloud_Height;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float3 _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2);
            float3 _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2;
            Unity_Multiply_float3_float3((_Property_2d6b9cde518e422a93f243169b594a66_Out_0.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2);
            float3 _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2);
            float3 _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            Unity_Add_float3(_Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2, _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2);
            description.Position = _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1);
            float4 _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0 = IN.ScreenPosition;
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_R_1 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[0];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_G_2 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[1];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_B_3 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[2];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_A_4 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[3];
            float _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2;
            Unity_Subtract_float(_Split_238e81d3fd0540deb7ece8a5eccb881d_A_4, 1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2);
            float _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2;
            Unity_Subtract_float(_SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2, _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2);
            float _Property_f588d37070e348b2b8646885a56c14fa_Out_0 = _Fade_Depth;
            float _Divide_26748a8584884003be3a46068c1a9850_Out_2;
            Unity_Divide_float(_Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2, _Property_f588d37070e348b2b8646885a56c14fa_Out_0, _Divide_26748a8584884003be3a46068c1a9850_Out_2);
            float _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            Unity_Saturate_float(_Divide_26748a8584884003be3a46068c1a9850_Out_2, _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1);
            surface.Alpha = _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_Speed;
        float _Cloud_Height;
        float4 _Noise_Remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curveture_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2);
            float _Property_3f88e6c692054523ba9288de1067b329_Out_0 = _Curveture_Radius;
            float _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2;
            Unity_Divide_float(_Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2, _Property_3f88e6c692054523ba9288de1067b329_Out_0, _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2);
            float _Power_c99c9141abe44cc78950e229089c9c63_Out_2;
            Unity_Power_float(_Divide_092294afb6404e7883452a61ce4ebe8d_Out_2, 3, _Power_c99c9141abe44cc78950e229089c9c63_Out_2);
            float3 _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_c99c9141abe44cc78950e229089c9c63_Out_2.xxx), _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2);
            float _Property_2d6b9cde518e422a93f243169b594a66_Out_0 = _Cloud_Height;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float3 _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2);
            float3 _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2;
            Unity_Multiply_float3_float3((_Property_2d6b9cde518e422a93f243169b594a66_Out_0.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2);
            float3 _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2);
            float3 _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            Unity_Add_float3(_Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2, _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2);
            description.Position = _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1);
            float4 _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0 = IN.ScreenPosition;
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_R_1 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[0];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_G_2 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[1];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_B_3 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[2];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_A_4 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[3];
            float _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2;
            Unity_Subtract_float(_Split_238e81d3fd0540deb7ece8a5eccb881d_A_4, 1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2);
            float _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2;
            Unity_Subtract_float(_SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2, _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2);
            float _Property_f588d37070e348b2b8646885a56c14fa_Out_0 = _Fade_Depth;
            float _Divide_26748a8584884003be3a46068c1a9850_Out_2;
            Unity_Divide_float(_Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2, _Property_f588d37070e348b2b8646885a56c14fa_Out_0, _Divide_26748a8584884003be3a46068c1a9850_Out_2);
            float _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            Unity_Saturate_float(_Divide_26748a8584884003be3a46068c1a9850_Out_2, _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1);
            surface.Alpha = _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float3 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.viewDirectionWS = input.interp2.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Rotate;
        float _Noise_Scale;
        float _Cloud_Speed;
        float _Cloud_Height;
        float4 _Noise_Remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Curveture_Radius;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2);
            float _Property_3f88e6c692054523ba9288de1067b329_Out_0 = _Curveture_Radius;
            float _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2;
            Unity_Divide_float(_Distance_a4d8cd8d45694158a9785173425ed4d4_Out_2, _Property_3f88e6c692054523ba9288de1067b329_Out_0, _Divide_092294afb6404e7883452a61ce4ebe8d_Out_2);
            float _Power_c99c9141abe44cc78950e229089c9c63_Out_2;
            Unity_Power_float(_Divide_092294afb6404e7883452a61ce4ebe8d_Out_2, 3, _Power_c99c9141abe44cc78950e229089c9c63_Out_2);
            float3 _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_c99c9141abe44cc78950e229089c9c63_Out_2.xxx), _Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2);
            float _Property_2d6b9cde518e422a93f243169b594a66_Out_0 = _Cloud_Height;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float3 _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2);
            float3 _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2;
            Unity_Multiply_float3_float3((_Property_2d6b9cde518e422a93f243169b594a66_Out_0.xxx), _Multiply_07fe3d9220ef4818a034ebe74de763eb_Out_2, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2);
            float3 _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_74b69d106b9d411f9d645bef91761f00_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2);
            float3 _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            Unity_Add_float3(_Multiply_6b78e2d576ab44319ba33ce32b67425c_Out_2, _Add_4385aa0256ea4a45a2402604d2f1a585_Out_2, _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2);
            description.Position = _Add_0ac9b725883c42ceb0d34c1cf96d5b9a_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_29db2a9e34314635b66e7c370e19649e_Out_0 = _Color_Valley;
            float4 _Property_da283fce167f4e29b3674417457a4b37_Out_0 = _Color_Peak;
            float _Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0 = _Noise_Edge_1;
            float _Property_5460f95a45104e74a1986042ad2376f2_Out_0 = _Noise_Edge_2;
            float4 _Property_6c8b3fe881874532a8321172d412989b_Out_0 = _Rotate;
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_R_1 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[0];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_G_2 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[1];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_B_3 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[2];
            float _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4 = _Property_6c8b3fe881874532a8321172d412989b_Out_0[3];
            float3 _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_6c8b3fe881874532a8321172d412989b_Out_0.xyz), _Split_407efd57f2054cd4874a2ec4ba6bd88a_A_4, _RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3);
            float _Property_c730677ce40344a1809519012fcf46f1_Out_0 = _Cloud_Speed;
            float _Multiply_946aea4bc3d54a439e271e188209c204_Out_2;
            Unity_Multiply_float_float(_Property_c730677ce40344a1809519012fcf46f1_Out_0, IN.TimeParameters.x, _Multiply_946aea4bc3d54a439e271e188209c204_Out_2);
            float2 _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_946aea4bc3d54a439e271e188209c204_Out_2.xx), _TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3);
            float _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0 = _Noise_Scale;
            float _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5c3e101630714d93bee42adfaaa8a45a_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2);
            float2 _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3);
            float _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4dfe088b54fd4c0086d08c6318801682_Out_3, _Property_876960bd5a074dacabbaeea8d19ee5a8_Out_0, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2);
            float _Add_13476c0850b94a2da537b039adc473c7_Out_2;
            Unity_Add_float(_GradientNoise_208db13d148e44369b5cbf9a5c1a214d_Out_2, _GradientNoise_2078ea39d25f4b7b8c470559a4815919_Out_2, _Add_13476c0850b94a2da537b039adc473c7_Out_2);
            float _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2;
            Unity_Divide_float(_Add_13476c0850b94a2da537b039adc473c7_Out_2, 2, _Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2);
            float _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1;
            Unity_Saturate_float(_Divide_978edc31baf8480fb50b0b3bcc61d7fe_Out_2, _Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1);
            float _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0 = _Noise_Power;
            float _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2;
            Unity_Power_float(_Saturate_0b4fcf55a0b049b4b4bca15395e1d60a_Out_1, _Property_e30a5a1411cf4d399ea863e5bdf7dd08_Out_0, _Power_64eb4ee905d944029cc4685e2799cbe6_Out_2);
            float4 _Property_3897c7a92d2844bf99d9478e258ba521_Out_0 = _Noise_Remap;
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[0];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[1];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[2];
            float _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4 = _Property_3897c7a92d2844bf99d9478e258ba521_Out_0[3];
            float4 _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4;
            float3 _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5;
            float2 _Combine_2e6904e0d734438d92284edf16e3a747_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_R_1, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_G_2, 0, 0, _Combine_2e6904e0d734438d92284edf16e3a747_RGBA_4, _Combine_2e6904e0d734438d92284edf16e3a747_RGB_5, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6);
            float4 _Combine_92409bb47bf7407db2431120f986515a_RGBA_4;
            float3 _Combine_92409bb47bf7407db2431120f986515a_RGB_5;
            float2 _Combine_92409bb47bf7407db2431120f986515a_RG_6;
            Unity_Combine_float(_Split_6e32f2bfe44946dbba5d58cf5facb6ee_B_3, _Split_6e32f2bfe44946dbba5d58cf5facb6ee_A_4, 0, 0, _Combine_92409bb47bf7407db2431120f986515a_RGBA_4, _Combine_92409bb47bf7407db2431120f986515a_RGB_5, _Combine_92409bb47bf7407db2431120f986515a_RG_6);
            float _Remap_e87737c171c644249d5624070a55262b_Out_3;
            Unity_Remap_float(_Power_64eb4ee905d944029cc4685e2799cbe6_Out_2, _Combine_2e6904e0d734438d92284edf16e3a747_RG_6, _Combine_92409bb47bf7407db2431120f986515a_RG_6, _Remap_e87737c171c644249d5624070a55262b_Out_3);
            float _Absolute_52f9990787ee4d32882433f93393157e_Out_1;
            Unity_Absolute_float(_Remap_e87737c171c644249d5624070a55262b_Out_3, _Absolute_52f9990787ee4d32882433f93393157e_Out_1);
            float _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3;
            Unity_Smoothstep_float(_Property_7ffb5b35f0404ad5bb9f560ac6649b13_Out_0, _Property_5460f95a45104e74a1986042ad2376f2_Out_0, _Absolute_52f9990787ee4d32882433f93393157e_Out_1, _Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3);
            float _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0 = _Base_Speed;
            float _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_4d4867ab04ec4f5094decf548af5ee13_Out_0, _Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2);
            float2 _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_ff932cbfdf604d4c8da3d3605d773337_Out_3.xy), float2 (1, 1), (_Multiply_03a336efcdc54c0a8bf52b41a784d9e9_Out_2.xx), _TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3);
            float _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0 = _Base_Scale;
            float _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_2d9e143d5e604fb9b170ca27c3dfbe75_Out_3, _Property_126d4d5428924f759b6fa970cb71c2e8_Out_0, _GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2);
            float _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0 = _Base_Strength;
            float _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6c3e00c6a9954b48b2044ed09b527086_Out_2, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2);
            float _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2;
            Unity_Add_float(_Smoothstep_35b490afb93848178baeb5cf20f9feef_Out_3, _Multiply_a6e6faf0a716498eb49f69487bafd418_Out_2, _Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2);
            float _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2;
            Unity_Add_float(1, _Property_1a7be7cdf7cf4a399489d1fbd2577a38_Out_0, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2);
            float _Divide_0b006a10ae5249c99f04ca020e507386_Out_2;
            Unity_Divide_float(_Add_c0da5ccedb934f7ebaa5153fd48b1e68_Out_2, _Add_722b7ca26d31468cb7bd15ecdde551e5_Out_2, _Divide_0b006a10ae5249c99f04ca020e507386_Out_2);
            float4 _Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3;
            Unity_Lerp_float4(_Property_29db2a9e34314635b66e7c370e19649e_Out_0, _Property_da283fce167f4e29b3674417457a4b37_Out_0, (_Divide_0b006a10ae5249c99f04ca020e507386_Out_2.xxxx), _Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3);
            float _Property_bc54bebcb75440499e3fd27961fc84dd_Out_0 = _Fresnel_Power;
            float _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_bc54bebcb75440499e3fd27961fc84dd_Out_0, _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3);
            float _Multiply_0052c1359335410fbdc0153da3f0f220_Out_2;
            Unity_Multiply_float_float(_Divide_0b006a10ae5249c99f04ca020e507386_Out_2, _FresnelEffect_323c8b263ac847288cea985c13edcd72_Out_3, _Multiply_0052c1359335410fbdc0153da3f0f220_Out_2);
            float _Property_28dca7ceb7d9484689ab1635c9d18323_Out_0 = _Fresnel_Opacity;
            float _Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2;
            Unity_Multiply_float_float(_Multiply_0052c1359335410fbdc0153da3f0f220_Out_2, _Property_28dca7ceb7d9484689ab1635c9d18323_Out_0, _Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2);
            float4 _Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2;
            Unity_Add_float4(_Lerp_c67a18facf254f80b1e01b5f3ce88c7b_Out_3, (_Multiply_41bb2647f9b04a46bdb2766081805d49_Out_2.xxxx), _Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2);
            float _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1);
            float4 _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0 = IN.ScreenPosition;
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_R_1 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[0];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_G_2 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[1];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_B_3 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[2];
            float _Split_238e81d3fd0540deb7ece8a5eccb881d_A_4 = _ScreenPosition_95b431ae71c843eabb077f6dc2ded2e6_Out_0[3];
            float _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2;
            Unity_Subtract_float(_Split_238e81d3fd0540deb7ece8a5eccb881d_A_4, 1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2);
            float _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2;
            Unity_Subtract_float(_SceneDepth_41e0dd4ddc55480f852f5b7b74bd96c6_Out_1, _Subtract_bbe46492be2a45c697fec473ca375e8e_Out_2, _Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2);
            float _Property_f588d37070e348b2b8646885a56c14fa_Out_0 = _Fade_Depth;
            float _Divide_26748a8584884003be3a46068c1a9850_Out_2;
            Unity_Divide_float(_Subtract_d05e4a428071425aa882d9183a9fdd4a_Out_2, _Property_f588d37070e348b2b8646885a56c14fa_Out_0, _Divide_26748a8584884003be3a46068c1a9850_Out_2);
            float _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            Unity_Saturate_float(_Divide_26748a8584884003be3a46068c1a9850_Out_2, _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1);
            surface.BaseColor = (_Add_f0c2a25202ae40f5ba6f4116f79efcb9_Out_2.xyz);
            surface.Alpha = _Saturate_c4452de48fe94e46a3f012faff955bfe_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}