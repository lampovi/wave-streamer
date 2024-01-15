set("init.allow_root",true)

# TODO: more customizable `serve_source()`
# TODO: use logging instead of `print()`
# TODO: improve list_assoc_update()
# TODO: remove `table = !ref_table` and find way to do `ref.get(ref_table)[key]`
#       or `!ref_table[key]`
# TODO: wait for positive response when sending tables
# TODO: save cover file and make access through http
# TODO: use threading

%include "utils.liq"
%include "functions.liq"

# URLs where to send data, where `$(s)` - stream (source) name
receiver    = "http://receiver:8002"
metadata_url  = receiver ^ "/track"
streams_url   = receiver ^ "/streams"
listeners_url = receiver ^ "/listeners?stream=$(s)"

# Base information about streams.
# We know that this kind of structure is awful

default_table = ref [
	("name", "default"),
	("title.en", "Default stream"),
	("title.ru", "Стандартный поток"),
	("description.en", "Main stream of Lampovi Wave"),
	("description.ru", "Основной поток Ламповой Волны"),
	("mount", "/default/stream.opus"),
	("mime", "audio/ogg"),
	("listeners", "0")]
legacy_table = ref [
	("name",           "legacy"),
	("title.en",       "Stream in AAC codec"),
	("title.ru",       "Поток в кодеке AAC"),
	("description.en", "If player doesn't support OPUS codec"),
	("description.ru", "Для случаев, когда кодек OPUS не поддерживается"),
	("mount",          "/legacy/stream.aac"),
	("mime",           "audio/aac"),
	("listeners",      "0")]
low_table = ref [
	("name",           "low"),
	("title.en",       "Low quality"),
	("title.ru",       "Сжатый поток"),
	("description.en", "For listeners with unstable connection"),
	("description.ru", "Для слушателей со слабым соединением"),
	("mount",          "/low/stream.opus"),
	("mime",           "audio/ogg"),
	("listeners",      "0")]
white_noise_table = ref [
	("name",           "white_noise"),
	("title.en",       "White noise"),
	("title.ru",       "Белый шум"),
	("description.en", "It's a music too"),
	("description.ru", "Это тоже музыка"),
	("mount",          "/white_noise/stream.wav"),
	("mime",           "audio/wav"),
	("listeners",      "0")]

send_tables(
	[
		# There should be all tables (not references to them)!
		!default_table,
		!legacy_table,
		!low_table,
		!white_noise_table
	],
	streams_url
)

regular_pl = playlist(
	mode = "randomize",
	reload_mode = "seconds",
	reload = 3600,
	"music/regular"
)

music_only_source = fallback(track_sensitive = false, [regular_pl, noise()])
music_only_source = normalize(music_only_source)
music_only_source = on_metadata(send_metadata(metadata_url), music_only_source)

serve_source( music_only_source, default_table, 8000, listeners_url,
	%opus(
        application = "audio",
        signal      = "music",
        channels    = 2))
serve_source( music_only_source, legacy_table,  8000, listeners_url,
	%fdkaac(
		channels    = 2,
		samplerate  = 44100,
		bandwidth   = "auto",
		bitrate     = 64,
		afterburner = false,
		aot         = "mpeg4_aac_lc",
		# transmux    = "adts",
		# sbr_mode    = false
))
serve_source( mean(music_only_source), low_table, 8000, listeners_url, 
	%opus(
        application = "audio",
        signal      = "music",
        channels    = 1))
serve_source( noise(), white_noise_table, 8000, listeners_url,
	%wav(
		channels    = 1,
		header      = false,
		samplesize  = 8))
