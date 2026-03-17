{ pkgs ? import <nixpkgs> {} }:

let
  pythonEnv = pkgs.python313.withPackages (ps: with ps; [
    pygobject3
    requests
	pycairo
  ]);
in

pkgs.mkShell {
	nativeBuildInputs = with pkgs; [
		gobject-introspection
		wrapGAppsHook3
		meson
		ninja
		pkg-config
		gettext
		desktop-file-utils
		appstream-glib
	];

	buildInputs = with pkgs; [
		python313
		python313Packages.pygobject3
		python313Packages.requests
		glib
		gtk4
		cairo
		pango
		libadwaita
		graphene

		pythonEnv
	];

	shellHook = ''
		if [ ! -d build ]; then
			echo "Meson setup..."
			meson setup build --prefix=$PWD/build
			echo "Compiling project..."
			meson compile -C build
		fi

		install() {
			meson install -C build
		}

		tcgd() {
			${pythonEnv}/bin/python $PWD/build/bin/catgirldownloader "$@"
		}
	'';
}