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
		makeWrapper
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
		zenity
		harfbuzz
		pythonEnv
		gsettings-desktop-schemas
		glib.dev
	];

	shellHook = ''
		# Путь к скомпилированным схемам GTK4 (найден через find)
		export GSETTINGS_SCHEMA_DIR="${pkgs.gtk4}/share/gsettings-schemas/gtk4-${pkgs.gtk4.version}/glib-2.0/schemas:${pkgs.glib}/share/glib-2.0/schemas"

		# Дополнительно добавляем путь в XDG_DATA_DIRS (GSettings также ищет там)
		export XDG_DATA_DIRS="${pkgs.gtk4}/share/gsettings-schemas/gtk4-${pkgs.gtk4.version}:$XDG_DATA_DIRS"

		if [ ! -d build ]; then
		echo "Meson setup..."
		meson setup build --prefix=$PWD/build
		echo "Compiling project..."
		meson compile -C build
		fi

		install() {
			meson install -C build
			wrapProgram "$PWD/build/bin/catgirldownloader" \
				--set PATH "${pythonEnv}/bin:$PATH" \
				--set GSETTINGS_SCHEMA_DIR "$GSETTINGS_SCHEMA_DIR" \
				--set GSK_RENDERER "gl" \
				--prefix GI_TYPELIB_PATH : "${pkgs.glib.out}/lib/girepository-1.0:${pkgs.gtk4.out}/lib/girepository-1.0:${pkgs.gdk-pixbuf.out}/lib/girepository-1.0:${pkgs.pango.out}/lib/girepository-1.0:${pkgs.harfbuzz.out}/lib/girepository-1.0"
		}

		tcgd() {
		if [ ! -f "$PWD/build/bin/.catgirldownloader-wrapped" ]; then
			echo "Program not wrapped, running install first..."
			install
		fi
		"$PWD/build/bin/catgirldownloader"
		}
	'';
}