namespace Oatmeal.Application;

public enum ShortcutModifier
{
    Command,
    Control,
    Option,
    Shift,
    Function,
}

public readonly record struct OatmealInputEvent(
    string Key,
    IReadOnlySet<ShortcutModifier> Modifiers
);

public interface IInputSink
{
    void OnInput(OatmealInputEvent input);
}
