# Gemini Unofficial Oxford Version [![Build Status](https://github.com/anishathalye/gemini/workflows/CI/badge.svg)](https://github.com/anishathalye/gemini/actions?query=workflow%3ACI)

This is an unofficial adaptation of the modern LaTeX [beamerposter] theme, Gemini, tailored for the University of Oxford.

<p align="center">
<a href="https://raw.githubusercontent.com/anishathalye/assets/master/gemini/poster-gemini.pdf">
<img src="https://raw.githubusercontent.com/MaxMLang/assets/master/ox-poster.png">
</a>
</p>

For a general-purpose beamer presentation theme, see [Auriga].

## Oxford Customizations

* Integrated University of Oxford branding guidelines
* Example templates featuring the Oxford color scheme and logo placement
* Additional font support to match Oxford's branding (where applicable)

## Dependencies

* A TeX installation that includes [LuaTeX]
    * `latexmk` is needed for using the provided `Makefile`
* LaTeX package dependencies including beamerposter (typically part of your TeX installation, available on [CTAN] if not)
* [Raleway] and [Lato] fonts, both available under Open Font License, and any additional fonts recommended by the University's branding guidelines

## Usage

1. Copy or clone the files from this repository

1. Configure `poster.tex` with your desired paper size, column layout, and scale adjustments as needed

1. Customize `beamercolorthemegemini.sty` by copying it and modifying the `\usecolortheme` line in `poster.tex` to theme your poster to Oxford's branding (optional but recommended for university-related presentations)

1. Use `make` to compile your poster

## FAQ

For common questions, such as adding an institution logo or customizing the color theme further, consult the [FAQ] in the Wiki.

## Themes

The Oxford version includes several color themes suitable for various types of presentations:

* `gemini` (default)
* `ox` (customized for University of Oxford branding)
* `mit`
* `labsix`

You're encouraged to create your own color theme or use the `ox` theme for presentations associated with the University.

## Design Goals

* **Minimal**: Focuses on readability and simplicity.
* **Batteries Included**: Ready to use with minimal setup.
* **Easy Theming**: Simplified process to create or modify themes.

## Contributing

Contributions such as bug reports, new themes, and enhancements are welcome! Design is subjective, so early feedback through issues or pull requests is encouraged.

## License

Copyright (c) 2018-2022 Anish Athalye. This unofficial Oxford version is released under the MIT License. See [LICENSE.md][license] for details.

[beamerposter]: https://github.com/deselaers/latex-beamerposter
[Auriga]: https://github.com/anishathalye/auriga
[LuaTeX]: http://www.luatex.org/
[CTAN]: https://ctan.org/
[Raleway]: https://www.fontsquirrel.com/fonts/raleway
[Lato]: https://www.fontsquirrel.com/fonts/lato
[license]: LICENSE.md
[FAQ]: https://github.com/anishathalye/gemini/wiki/FAQ
