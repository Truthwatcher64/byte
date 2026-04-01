public class Views.Folder : Gtk.EventBox {
    private string folder_uri;
    private Gee.ArrayList<Objects.Track?> all_tracks;

    private Gtk.Label title_label;
    private Gtk.Label path_label;
    private Gtk.ListBox listbox;

    public Folder () {
        Object ();
    }

    construct {
        get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        get_style_context ().add_class ("w-round");

        var back_button = new Gtk.Button.from_icon_name ("byte-arrow-back-symbolic", Gtk.IconSize.MENU);
        back_button.can_focus = false;
        back_button.margin = 3;
        back_button.margin_bottom = 6;
        back_button.margin_top = 6;
        back_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        back_button.get_style_context ().add_class ("label-color-primary");

        var center_label = new Gtk.Label (_("Folder"));
        center_label.use_markup = true;
        center_label.valign = Gtk.Align.CENTER;
        center_label.get_style_context ().add_class ("h3");
        center_label.get_style_context ().add_class ("label-color-primary");

        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        header_box.get_style_context ().add_class (Gtk.STYLE_CLASS_BACKGROUND);
        header_box.pack_start (back_button, false, false, 0);
        header_box.set_center_widget (center_label);

        title_label = new Gtk.Label ("");
        title_label.get_style_context ().add_class ("font-bold");
        title_label.wrap = true;
        title_label.wrap_mode = Pango.WrapMode.CHAR;
        title_label.halign = Gtk.Align.CENTER;

        path_label = new Gtk.Label ("");
        path_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
        path_label.wrap = true;
        path_label.wrap_mode = Pango.WrapMode.CHAR;
        path_label.halign = Gtk.Align.CENTER;

        listbox = new Gtk.ListBox ();
        listbox.expand = true;

        var play_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.MENU);
        play_button.always_show_image = true;
        play_button.label = _("Play");
        play_button.hexpand = true;
        play_button.get_style_context ().add_class ("home-button");
        play_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var shuffle_button = new Gtk.Button.from_icon_name ("media-playlist-shuffle-symbolic", Gtk.IconSize.MENU);
        shuffle_button.always_show_image = true;
        shuffle_button.label = _("Shuffle");
        shuffle_button.hexpand = true;
        shuffle_button.get_style_context ().add_class ("home-button");
        shuffle_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var action_grid = new Gtk.Grid ();
        action_grid.margin = 6;
        action_grid.column_spacing = 12;
        action_grid.add (play_button);
        action_grid.add (shuffle_button);

        var detail_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        detail_box.get_style_context ().add_class (Granite.STYLE_CLASS_WELCOME);
        detail_box.pack_start (title_label, false, false, 3);
        detail_box.pack_start (path_label, false, false, 0);

        var content_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        content_box.expand = true;
        content_box.pack_start (detail_box, false, false, 0);
        content_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, false, 0);
        content_box.pack_start (action_grid, false, false, 0);
        content_box.pack_start (listbox, true, true, 0);

        var main_scrolled = new Gtk.ScrolledWindow (null, null);
        main_scrolled.margin_bottom = 48;
        main_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        main_scrolled.expand = true;
        main_scrolled.add (content_box);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.expand = true;
        main_box.pack_start (header_box, false, false, 0);
        main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, false, 0);
        main_box.pack_start (main_scrolled, true, true, 0);

        add (main_box);

        back_button.clicked.connect (() => {
            Byte.navCtrl.pop ();
        });

        play_button.clicked.connect (() => {
            if (all_tracks != null) {
                Byte.utils.set_items (all_tracks, false, null);
            }
        });

        shuffle_button.clicked.connect (() => {
            if (all_tracks != null) {
                Byte.utils.set_items (all_tracks, true, null);
            }
        });

        listbox.row_activated.connect ((row) => {
            var item = row as Widgets.TrackAlbumRow;
            Byte.utils.set_items (
                all_tracks,
                Byte.settings.get_boolean ("shuffle-mode"),
                item.track
            );
        });

        show_all ();
    }

    public void set_folder (string folder_uri, Gee.ArrayList<Objects.Track?> tracks) {
        this.folder_uri = folder_uri;
        this.all_tracks = tracks;

        try {
            var folder_file = GLib.File.new_for_uri (folder_uri);
            title_label.label = folder_file.get_basename ();
        } catch (Error e) {
            title_label.label = folder_uri;
        }

        string folder_name = folder_uri.replace("file://", "");
        folder_name = folder_name.substring(1);

        path_label.label = folder_name;

        listbox.foreach ((widget) => {
            widget.destroy ();
        });

        foreach (var track in tracks) {
            var row = new Widgets.TrackAlbumRow (track);
            listbox.add (row);
        }

        listbox.show_all ();
    }
}
