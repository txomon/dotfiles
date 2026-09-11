#include <windows.h>
#include <objbase.h>
#include <string.h>
#define EXPORT __declspec(dllexport)
static HRESULT ret_version(unsigned short** out){
    if(!out) return E_POINTER;
    static const unsigned short v[] = {'1','3','0','.','0','.','2','8','4','9','.','6','8',0};
    size_t n = sizeof(v);
    void* p = CoTaskMemAlloc(n);
    if(!p) return E_OUTOFMEMORY;
    memcpy(p, v, n);
    *out = (unsigned short*)p;
    return S_OK;
}
EXPORT HRESULT GetAvailableCoreWebView2BrowserVersionString(const unsigned short* folder, unsigned short** versionInfo){
    (void)folder; return ret_version(versionInfo);
}
EXPORT HRESULT GetAvailableCoreWebView2BrowserVersionStringWithOptions(const unsigned short* folder, void* options, unsigned short** versionInfo){
    (void)folder;(void)options; return ret_version(versionInfo);
}
EXPORT HRESULT CompareBrowserVersions(const unsigned short* v1, const unsigned short* v2, int* result){
    (void)v1;(void)v2; if(result)*result=0; return S_OK;
}
EXPORT HRESULT CreateCoreWebView2Environment(void* handler){
    (void)handler; return S_OK;   /* pending forever: never invoke handler -> pcon waits, no retry */
}
EXPORT HRESULT CreateCoreWebView2EnvironmentWithOptions(const unsigned short* folder, const unsigned short* udf, void* options, void* handler){
    (void)folder;(void)udf;(void)options;(void)handler; return S_OK;   /* pending forever */
}
BOOL WINAPI DllMain(HINSTANCE h, DWORD r, LPVOID x){(void)h;(void)r;(void)x; return TRUE;}
