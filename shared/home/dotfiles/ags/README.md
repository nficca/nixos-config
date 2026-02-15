# AGS Configuration

AGS (Astal + GJS) is a TypeScript/JSX framework for building custom desktop shells on Wayland. It uses GTK4 for rendering and provides bindings to system services (battery, network, bluetooth, etc.) through the Astal library.

## How It Works

- `app.tsx` is the entry point
- Components are written in TSX using GTK4 widgets
- Styles are defined in `style.scss`
- Astal libraries provide reactive bindings to system state (e.g., `AstalNiri` for niri workspace info)

## Development Setup

After a fresh clone, generate TypeScript types:

```sh
ags types -u -d ~/.config/ags
```

Run the shell:

```sh
ags run ~/.config/ags/app.tsx
```

## Resources

- [AGS Documentation](https://aylur.github.io/ags/)
- [Astal Niri PR](https://github.com/Aylur/astal/pull/70)
