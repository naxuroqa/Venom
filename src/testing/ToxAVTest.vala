/*
 * Example taken from https://wiki.gnome.org/Projects/Vala/GStreamerSample
 */

using Gtk;
using Gst;

public class VideoSample : Window {

    private DrawingArea drawing_area;
    private Pipeline pipeline;
    private Element src;
    private Element sink;
    private ulong xid;

    public VideoSample () {
        create_widgets ();
        setup_gst_pipeline ();
    }

    private void create_widgets () {
        var vbox = new Box (Orientation.VERTICAL, 0);
        this.drawing_area = new DrawingArea ();
        this.drawing_area.realize.connect(on_realize);
        vbox.pack_start (this.drawing_area, true, true, 0);

        var play_button = new Button.from_stock (Stock.MEDIA_PLAY);
        play_button.clicked.connect (on_play);
        var stop_button = new Button.from_stock (Stock.MEDIA_STOP);
        stop_button.clicked.connect (on_stop);
        var quit_button = new Button.from_stock (Stock.QUIT);
        quit_button.clicked.connect (Gtk.main_quit);

        var bb = new ButtonBox (Orientation.HORIZONTAL);
        bb.add (play_button);
        bb.add (stop_button);
        bb.add (quit_button);
        vbox.pack_start (bb, false, true, 0);

        add (vbox);
    }

    private void setup_gst_pipeline () {
        this.pipeline = new Pipeline ("mypipeline");
        this.src = ElementFactory.make ("videotestsrc", "video");
        this.sink = ElementFactory.make ("xvimagesink", "sink");
        this.pipeline.add_many (this.src, this.sink);
        this.src.link (this.sink);
    }

    private void on_realize() {
        this.xid = (ulong)Gdk.X11Window.get_xid(this.drawing_area.get_window());
    }

    private void on_play () {
        var xoverlay = this.sink as XOverlay;
        xoverlay.set_xwindow_id (this.xid);
        this.pipeline.set_state (State.PLAYING);
    }

    private void on_stop () {
        this.pipeline.set_state (State.READY);
    }

    public static int main (string[] args) {
        Gst.init (ref args);
        Gtk.init (ref args);

        var sample = new VideoSample ();
        sample.show_all ();

        Gtk.main ();

        return 0;
    }
}
