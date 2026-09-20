using Oatmeal.Application;

namespace Oatmeal.Platform.Windows.Input;

public sealed class WindowsInputBackend
{
    private readonly IInputSink sink;

    public WindowsInputBackend(IInputSink sink)
    {
        this.sink = sink ?? throw new ArgumentNullException(nameof(sink));
    }

    public bool IsRunning { get; private set; }

    public void Start() => IsRunning = true;

    public void Stop() => IsRunning = false;

    public bool ProcessKeyEvent(
        uint virtualKey,
        bool control,
        bool alt,
        bool shift,
        bool function,
        string? text = null
    )
    {
        if (!IsRunning)
            return false;

        var key = WindowsKeyTranslator.Translate(virtualKey, text);
        if (key is null)
            return false;

        var modifiers = new HashSet<ShortcutModifier>();
        if (control)
            modifiers.Add(ShortcutModifier.Control);
        if (alt)
            modifiers.Add(ShortcutModifier.Option);
        if (shift)
            modifiers.Add(ShortcutModifier.Shift);
        if (function)
            modifiers.Add(ShortcutModifier.Function);

        sink.OnInput(new OatmealInputEvent(key, modifiers));
        return true;
    }
}

internal static class WindowsKeyTranslator
{
    public static string? Translate(uint virtualKey, string? text)
    {
        if (!string.IsNullOrWhiteSpace(text))
            return text.ToLowerInvariant();

        return virtualKey switch
        {
            0x08 => "delete",
            0x09 => "tab",
            0x0D => "return",
            0x1B => "escape",
            0x20 => "space",
            0x21 => "pageup",
            0x22 => "pagedown",
            0x23 => "end",
            0x24 => "home",
            0x25 => "left",
            0x26 => "up",
            0x27 => "right",
            0x28 => "down",
            0x2D => "insert",
            0x2E => "delete",
            >= 0x30 and <= 0x39 => ((char)virtualKey).ToString().ToLowerInvariant(),
            >= 0x41 and <= 0x5A => ((char)virtualKey).ToString().ToLowerInvariant(),
            >= 0x70 and <= 0x7B => $"f{virtualKey - 0x6F}",
            _ => null,
        };
    }
}
