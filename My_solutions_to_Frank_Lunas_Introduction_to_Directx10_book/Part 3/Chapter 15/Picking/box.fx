#include "lighthelper.fx"

DepthStencilState DisableDepth
{
    DepthEnable = FALSE;
    DepthWriteMask = ZERO;
};

BlendState Transparency
{
    AlphaToCoverageEnable = FALSE;
    BlendEnable[0] = TRUE;
    SrcBlend = SRC_ALPHA;
    DestBlend = INV_SRC_ALPHA;
    BlendOp = ADD;
    SrcBlendAlpha = ZERO;
    DestBlendAlpha = ZERO;
    BlendOpAlpha = ADD;
    RenderTargetWriteMask[0] = 0x0F;
};

RasterizerState MyRS
{
	FILLMODE = WIREFRAME;
	CULLMODE = NONE;
};

cbuffer cbPerObject
{
	float4x4 gWorld;
	float4x4 gWVP; 
	float4x4 gTexMtx;
};

cbuffer cbPerFrame
{
	Light gLight;
	float3 gEyePosW;
};

struct VS_IN
{
	float3 posL     : POSITION;
	float3 tangentL : TANGENT;
	float3 normalL  : NORMAL;
	float2 texC     : TEXCOORD;
};

struct VS_OUT
{
	float4 posH     : SV_POSITION;
    float3 posW     : POSITION;
    float3 tangentW : TANGENT;
    float3 normalW  : NORMAL;
    float2 texC     : TEXCOORD0;
};
 
VS_OUT VS(VS_IN vIn)
{
	VS_OUT vOut;
	
	// Transform to world space space.
	vOut.posW     = mul(float4(vIn.posL, 1.0f), gWorld);
	vOut.tangentW = mul(float4(vIn.tangentL, 0.0f), gWorld);
	vOut.normalW  = mul(float4(vIn.normalL, 0.0f), gWorld);
		
	// Transform to homogeneous clip space.
	vOut.posH = mul(float4(vIn.posL, 1.0f), gWVP);
	
	
	// Output vertex attributes for interpolation across triangle.
	vOut.texC = mul(float4(vIn.texC, 0.0f, 1.0f), gTexMtx);
	
	return vOut;
}

float4 PS(VS_OUT pIn) : SV_Target
{
	return float4(0.0f, 1.0f, 0.0f, 0.5f);
}


technique10 BoxTech
{
    pass P0
    {
        SetVertexShader( CompileShader( vs_4_0, VS() ) );
        SetGeometryShader( NULL );
        SetPixelShader( CompileShader( ps_4_0, PS() ) );
        
        SetBlendState(Transparency, float4(0.0f, 0.0f, 0.0f, 0.0f), 0xffffffff);
        
        // Turn off depth test so that there is no z-fighting when we render
        // the picked triangle twice.
		SetRasterizerState( MyRS );
        SetDepthStencilState( DisableDepth, 0 );
		
    }
}
