public class Views.Home : Gtk.EventBox {
    private const int PIN_COUNT = 5;

    private Gtk.ListBox listbox;
    private Gee.ArrayList<Objects.Track?> all_tracks;
    private Widgets.HomeButton[] pinned_buttons;
    private string[] pinned_icons = {
        "starred-symbolic",
        "playlist-symbolic",
        "folder-music-symbolic",
        "byte-album-symbolic",
        "byte-favorite-symbolic"
    };
    private string[] pinned_entries;
    
    construct {
        get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        get_style_context ().add_class ("w-round");

        all_tracks = Byte.database.get_tracks_recently_added ();

        var library_label = new Gtk.Label ("<b>%s</b>".printf (_("Library")));
        library_label.get_style_context ().add_class ("font-bold");
        library_label.get_style_context ().add_class ("h3");
        library_label.get_style_context ().add_class ("label-color-primary");
        library_label.margin_start = 9;
        library_label.margin_top = 6;
        library_label.halign =Gtk.Align.START;
        library_label.use_markup = true;
        
        var recently_added_label = new Gtk.Label ("<b>%s</b>".printf (_("Recently added")) + " <small>%s</small>".printf (_("(last 100)")));
        recently_added_label.get_style_context ().add_class ("label-color-primary");
        recently_added_label.get_style_context ().add_class ("h3");
        recently_added_label.margin_start = 9;
        recently_added_label.halign =Gtk.Align.START;
        recently_added_label.use_markup = true;

        var pinned_label = new Gtk.Label ("<b>%s</b>".printf (_("Pinned")));
        pinned_label.get_style_context ().add_class ("font-bold");
        pinned_label.get_style_context ().add_class ("h3");
        pinned_label.get_style_context ().add_class ("label-color-primary");
        pinned_label.margin_start = 9;
        pinned_label.margin_top = 6;
        pinned_label.halign = Gtk.Align.START;
        pinned_label.use_markup = true;

        pinned_buttons = new Widgets.HomeButton[PIN_COUNT];
        pinned_entries = new string[PIN_COUNT];

        for (int i = 0; i < PIN_COUNT; i++) {
            pinned_buttons[i] = new Widgets.HomeButton (_("Pinned %i").printf (i + 1), pinned_icons[0]);
            pinned_buttons[i].tooltip_text = _("Right click to configure");

            int pin_index = i;
            pinned_buttons[i].clicked.connect (() => {
                open_pinned_target (pin_index);
            });

            pinned_buttons[i].button_press_event.connect ((event) => {
                if (event.button == 3) {
                    show_pinned_menu (pin_index, event);
                    return true;
                }

                return false;
            });
        }

        var pinned_grid = new Gtk.Grid ();
        pinned_grid.column_spacing = 6;
        pinned_grid.margin = 6;
        pinned_grid.column_homogeneous = true;
        pinned_grid.attach (pinned_buttons[0], 0, 0, 1, 1);
        pinned_grid.attach (pinned_buttons[1], 1, 0, 1, 1);
        pinned_grid.attach (pinned_buttons[2], 2, 0, 1, 1);
        pinned_grid.attach (pinned_buttons[3], 3, 0, 1, 1);
        pinned_grid.attach (pinned_buttons[4], 4, 0, 1, 1);

        var playlists_button = new Widgets.HomeButton (_("Playlists"), "playlist-symbolic");
        var albums_button = new Widgets.HomeButton (_("Albums"), "byte-album-symbolic");
        var songs_button = new Widgets.HomeButton (_("Songs"), "folder-music-symbolic");
        var folders_button = new Widgets.HomeButton (_("Folder"), "folder-music-symbolic");
        var artists_button = new Widgets.HomeButton (_("Artists"), "byte-artist-symbolic");
        var radios_button = new Widgets.HomeButton (_("Radios"), "byte-radio-symbolic");
        var favorites_button = new Widgets.HomeButton (_("Favorites"), "byte-favorite-symbolic");

        listbox = new Gtk.ListBox ();
        listbox.expand = true;

        var tracks_scrolled = new Gtk.ScrolledWindow (null, null);
        tracks_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        tracks_scrolled.margin_top = 6;
        tracks_scrolled.margin_bottom = 3;
        tracks_scrolled.expand = true;
        tracks_scrolled.add (listbox);

        var items_grid = new Gtk.Grid ();
        items_grid.row_spacing = 6;
        items_grid.column_spacing = 6;
        items_grid.margin = 6;
        items_grid.column_homogeneous = true;
        items_grid.row_homogeneous = true;
        items_grid.get_style_context ().add_class (Granite.STYLE_CLASS_WELCOME);
        items_grid.attach (songs_button,     0, 0, 1, 1);
        items_grid.attach (playlists_button,    1, 0, 1, 1);
        items_grid.attach (albums_button, 0, 1, 1, 1);
        items_grid.attach (artists_button, 1, 1, 1, 1);
        items_grid.attach (favorites_button,    0, 2, 1, 1);
        items_grid.attach (radios_button,   1, 2, 1, 1);
        items_grid.attach (folders_button, 0, 3, 1, 1);

        var pinned_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        pinned_box.hexpand = false;
        pinned_box.pack_start (pinned_label, false, false, 0);
        pinned_box.pack_start (pinned_grid, false, false, 0);

        var library_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        library_box.vexpand = true;
        library_box.hexpand = false;
        library_box.pack_start (library_label, false, false, 0);
        library_box.pack_start (items_grid, false, false, 0);
        library_box.pack_start (recently_added_label, false, false, 0);
        library_box.pack_start (tracks_scrolled, true, true, 0);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.pack_start (pinned_box, false, false, 0);
        main_box.pack_start (library_box, true, true, 0);

        add (main_box);
        load_pinned_entries ();
        add_all_tracks ();

        albums_button.clicked.connect (() => {
            if (!Byte.navCtrl.has_key ("albums_view")) {
                var view = new Views.Albums ();
                Byte.navCtrl.add_named (view, "albums_view");
            }

            Byte.navCtrl.push ("albums_view");
        });

        songs_button.clicked.connect (() => {
            if (!Byte.navCtrl.has_key ("tracks_view")) {
                var view = new Views.Tracks ();
                Byte.navCtrl.add_named (view, "tracks_view");
            }

            Byte.navCtrl.push ("tracks_view");
        });

        artists_button.clicked.connect (() => {
            if (!Byte.navCtrl.has_key ("artists_view")) {
                var view = new Views.Artists ();
                Byte.navCtrl.add_named (view, "artists_view");
            }

            Byte.navCtrl.push ("artists_view");
        });

        radios_button.clicked.connect (() => {
            if (!Byte.navCtrl.has_key ("radios_view")) {
                var view = new Views.Radios ();
                Byte.navCtrl.add_named (view, "radios_view");
            }

            Byte.navCtrl.push ("radios_view");
        });

        playlists_button.clicked.connect (() => {
            if (!Byte.navCtrl.has_key ("playlists_view")) {
                var view = new Views.Playlists ();
                Byte.navCtrl.add_named (view, "playlists_view");
            }

            Byte.navCtrl.push ("playlists_view");
        });

        folders_button.clicked.connect (() => {
            string folder = Byte.scan_service.choose_folder (Byte.instance.main_window);
            if (folder != null) {
                var tracks = Byte.database.get_all_tracks_by_folder (folder);
                if (tracks.size > 0) {
                    Byte.utils.set_items (tracks, false, null);

                    if (Byte.folder_view == null) {
                        Byte.folder_view = new Views.Folder ();
                        Byte.navCtrl.add_named (Byte.folder_view, "folder_view");
                    }

                    Byte.folder_view.set_folder (folder, tracks);
                    Byte.navCtrl.push ("folder_view");
                } else {
                    var dialog = new Gtk.MessageDialog (
                        null,
                        Gtk.DialogFlags.MODAL,
                        Gtk.MessageType.INFO,
                        Gtk.ButtonsType.OK,
                        _("No tracks found in selected folder")
                    );
                    dialog.run ();
                    dialog.destroy ();
                }
            }
        });

        favorites_button.clicked.connect (() => {
            if (!Byte.navCtrl.has_key ("favorites_view")) {
                var view = new Views.Favorites ();
                Byte.navCtrl.add_named (view, "favorites_view");
            }

            Byte.navCtrl.push ("favorites_view");
        });

        listbox.row_activated.connect ((row) => {
            var item = row as Widgets.TrackRow;
            
            Byte.utils.set_items (
                all_tracks,
                Byte.settings.get_boolean ("shuffle-mode"),
                item.track
            );
        });

        Byte.database.adden_new_track.connect ((track) => {
            Idle.add (() => {
                if (track != null) {
                    var row = new Widgets.TrackRow (track, 3);
                    listbox.insert (row, 0);
                    all_tracks.insert (0, track);
                    listbox.show_all ();

                    if (all_tracks.size > 100) {
                        all_tracks.remove_at (100);
                        var _row = listbox.get_row_at_index (100);
                        _row.destroy ();
                    }
                }

                return false;
            });
        });

        Byte.database.reset_library.connect (() => {
            listbox.foreach ((widget) => {
                Idle.add (() => {
                    widget.destroy (); 
    
                    return false;
                });
            });
        });

        Byte.scan_service.sync_started.connect (() => {
            playlists_button.sensitive = false;
            albums_button.sensitive = false;
            songs_button.sensitive = false;
            artists_button.sensitive = false;
            radios_button.sensitive = false;
            favorites_button.sensitive = false;
        });

        Byte.scan_service.sync_finished.connect (() => {
            playlists_button.sensitive = true;
            albums_button.sensitive = true;
            songs_button.sensitive = true;
            artists_button.sensitive = true;
            radios_button.sensitive = true;
            favorites_button.sensitive = true;
        });
    }

    public void add_all_tracks () {
        foreach (var track in all_tracks) {
            var row = new Widgets.TrackRow (track, 3);

            listbox.add (row);
            listbox.show_all ();
        }
    }

    private void load_pinned_entries () {
        var saved_entries = Byte.settings.get_strv ("pinned-items");

        for (int i = 0; i < PIN_COUNT; i++) {
            if (i < saved_entries.length) {
                pinned_entries[i] = saved_entries[i];
            } else {
                pinned_entries[i] = "";
            }

            refresh_pinned_button (i);
        }

        save_pinned_entries ();
    }

    private void save_pinned_entries () {
        string[] values = {};

        for (int i = 0; i < PIN_COUNT; i++) {
            values += pinned_entries[i];
        }

        Byte.settings.set_strv ("pinned-items", values);
    }

    private void refresh_pinned_button (int index) {
        string entry = pinned_entries[index];
        var button = pinned_buttons[index];

        if (entry == "") {
            button.primary_name = _("Pinned %i").printf (index + 1);
            button.primary_icon = pinned_icons[index];
            return;
        }

        if (entry.has_prefix ("folder::")) {
            string folder_uri = entry.substring (8);
            var folder_file = File.new_for_uri (folder_uri);

            button.primary_name = folder_file.get_basename () ?? _("Folder");
            button.primary_icon = "folder-music-symbolic";
            return;
        }

        if (entry.has_prefix ("playlist::")) {
            string id_string = entry.substring (10);
            int playlist_id = int.parse (id_string);
            var playlist = Byte.database.get_playlist_by_id (playlist_id);

            if (playlist.id == 0) {
                pinned_entries[index] = "";
                button.primary_name = _("Pinned %i").printf (index + 1);
                button.primary_icon = pinned_icons[index];
                save_pinned_entries ();
                return;
            }

            button.primary_name = playlist.title;
            button.primary_icon = "playlist-symbolic";
            return;
        }

        pinned_entries[index] = "";
        button.primary_name = _("Pinned %i").printf (index + 1);
        button.primary_icon = pinned_icons[index];
        save_pinned_entries ();
    }

    private void show_pinned_menu (int index, Gdk.EventButton event) {
        var menu = new Gtk.Menu ();

        var set_folder_item = new Gtk.MenuItem.with_label (_("Set Folder"));
        set_folder_item.activate.connect (() => {
            set_pinned_folder (index);
        });

        var set_playlist_item = new Gtk.MenuItem.with_label (_("Set Playlist"));
        set_playlist_item.activate.connect (() => {
            set_pinned_playlist (index);
        });

        menu.append (set_folder_item);
        menu.append (set_playlist_item);

        if (pinned_entries[index] != "") {
            var clear_item = new Gtk.MenuItem.with_label (_("Clear"));
            clear_item.activate.connect (() => {
                pinned_entries[index] = "";
                refresh_pinned_button (index);
                save_pinned_entries ();
            });
            menu.append (clear_item);
        }

        menu.show_all ();
        menu.popup_at_pointer (event);
    }

    private void open_pinned_target (int index) {
        string entry = pinned_entries[index];

        if (entry == "") {
            configure_pinned_target (index);
            return;
        }

        if (entry.has_prefix ("folder::")) {
            string folder_uri = entry.substring (8);
            open_folder_target (folder_uri, true);
            return;
        }

        if (entry.has_prefix ("playlist::")) {
            string id_string = entry.substring (10);
            int playlist_id = int.parse (id_string);
            open_playlist_target (playlist_id, true);
            return;
        }

        pinned_entries[index] = "";
        refresh_pinned_button (index);
        save_pinned_entries ();
    }

    private void configure_pinned_target (int index) {
        var chooser = new Gtk.MessageDialog (
            Byte.instance.main_window,
            Gtk.DialogFlags.MODAL,
            Gtk.MessageType.QUESTION,
            Gtk.ButtonsType.NONE,
            _("Choose what to pin")
        );

        chooser.secondary_text = _("You can pin either a folder or a playlist.");
        
        chooser.add_button (_("Folder"), 2);
        chooser.add_button (_("Playlist"), 1);
        chooser.add_button (_("Cancel"), Gtk.ResponseType.CANCEL);

        var response = chooser.run ();
        chooser.destroy ();

        if (response == 2) {
            set_pinned_folder (index);
        } else if (response == 1) {
            set_pinned_playlist (index);
        }
    }

    private void set_pinned_folder (int index) {
        string folder = Byte.scan_service.choose_folder (Byte.instance.main_window);

        if (folder == null) {
            return;
        }

        pinned_entries[index] = "folder::" + folder;
        refresh_pinned_button (index);
        save_pinned_entries ();
    }

    private void set_pinned_playlist (int index) {
        var playlists = Byte.database.get_all_playlists ();

        if (playlists.size == 0) {
            var dialog = new Gtk.MessageDialog (
                Byte.instance.main_window,
                Gtk.DialogFlags.MODAL,
                Gtk.MessageType.INFO,
                Gtk.ButtonsType.OK,
                _("No playlists available")
            );

            dialog.run ();
            dialog.destroy ();
            return;
        }

        var dialog = new Gtk.Dialog.with_buttons (
            _("Select Playlist"),
            Byte.instance.main_window,
            Gtk.DialogFlags.MODAL,
            _("Cancel"), Gtk.ResponseType.CANCEL,
            _("Save"), Gtk.ResponseType.OK
        );

        dialog.set_default_response (Gtk.ResponseType.OK);

        var playlist_combo = new Gtk.ComboBoxText ();
        foreach (var playlist in playlists) {
            playlist_combo.append ("%i".printf (playlist.id), playlist.title);
        }
        playlist_combo.active = 0;

        var content = dialog.get_content_area ();
        content.margin = 12;
        content.add (playlist_combo);

        dialog.show_all ();

        if (dialog.run () == Gtk.ResponseType.OK) {
            string? selected_id = playlist_combo.get_active_id ();
            if (selected_id != null) {
                pinned_entries[index] = "playlist::" + selected_id;
                refresh_pinned_button (index);
                save_pinned_entries ();
            }
        }

        dialog.destroy ();
    }

    private void open_folder_target (string folder, bool show_errors) {
        var tracks = Byte.database.get_all_tracks_by_folder (folder);
        if (tracks.size > 0) {
            Byte.utils.set_items (tracks, false, null);

            if (Byte.folder_view == null) {
                Byte.folder_view = new Views.Folder ();
                Byte.navCtrl.add_named (Byte.folder_view, "folder_view");
            }

            Byte.folder_view.set_folder (folder, tracks);
            Byte.navCtrl.push ("folder_view");
        } else if (show_errors) {
            var dialog = new Gtk.MessageDialog (
                Byte.instance.main_window,
                Gtk.DialogFlags.MODAL,
                Gtk.MessageType.INFO,
                Gtk.ButtonsType.OK,
                _("No tracks found in selected folder")
            );
            dialog.run ();
            dialog.destroy ();
        }
    }

    private void open_playlist_target (int playlist_id, bool show_errors) {
        var playlist = Byte.database.get_playlist_by_id (playlist_id);

        if (playlist.id == 0) {
            if (show_errors) {
                var dialog = new Gtk.MessageDialog (
                    Byte.instance.main_window,
                    Gtk.DialogFlags.MODAL,
                    Gtk.MessageType.INFO,
                    Gtk.ButtonsType.OK,
                    _("Playlist not found")
                );
                dialog.run ();
                dialog.destroy ();
            }

            return;
        }

        string key = "playlist-%i".printf (playlist.id);
        if (!Byte.navCtrl.has_key (key)) {
            var playlist_view = new Views.Playlist (playlist);
            Byte.navCtrl.add_named (playlist_view, key);
        }

        Byte.navCtrl.push (key);
    }
}
