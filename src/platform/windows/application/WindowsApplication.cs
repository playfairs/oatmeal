using Oatmeal.Application;
using Oatmeal.Platform.Windows.Input;

namespace Oatmeal.Platform.Windows.Application;

public sealed class WindowsApplication : IDisposable
{
    private readonly WindowsInputBackend input;

    public WindowsApplication(IInputSink sink)
    {
        input = new WindowsInputBackend(sink);
    }

    public bool IsRunning { get; private set; }

    public WindowsInputBackend Input => input;

    public void Start()
    {
        if (IsRunning)
            return;

        input.Start();
        IsRunning = true;
    }

    public void Stop()
    {
        if (!IsRunning)
            return;

        input.Stop();
        IsRunning = false;
    }

    public void Dispose()
    {
        Stop();
    }
}
