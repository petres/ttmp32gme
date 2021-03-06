package TTMp32Gme::Build::Perl;

use strict;
use warnings;

use File::Find;
use Path::Class;
use Cwd;

require Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw(loadFile get_local_storage get_par_tmp loadTemplates loadAssets openBrowser);

my $maindir = cwd();

sub loadFile {
	my $path    = $_[0];
	my $file    = file($path);
	my $content = $file->slurp( iomode => '<:raw' );
	return $content;
}

sub get_local_storage {
	my $retdir;
	if ( defined $ENV{'APPDATA'} ) {
		$retdir = dir( $ENV{'APPDATA'}, 'ttmp32gme' );
	} elsif ( defined $ENV{'HOME'} ) {
		if ( $^O eq 'darwin' ) {
			$retdir = dir( $ENV{'HOME'}, 'Library', 'Application Support', 'ttmp32gme' );
		} else {
			$retdir = dir( $ENV{'HOME'}, '.ttmp32gme' );
		}
	} else {
		$retdir = dir($maindir);
	}
	$retdir->mkpath();
	return $retdir;
}

sub get_par_tmp {
	return dir($maindir);
}

sub loadTemplates {
	my %templates = ();
	find(
		sub {
			my ($name) = $File::Find::name =~ /.*\/(.*)\.html$/;
			$templates{$name} = Text::Template->new( TYPE => 'FILE', SOURCE => $_ )
				if -f;
		},
		'templates/'
	);
	return %templates;
}

sub loadAssets {
	my %assets = ();
	find(
		sub {
			my $content = loadFile($_) if -f;
			my $mime;
			if ( $_ =~ /.js$/ ) {
				$mime = 'text/javascript';
			} elsif ( $_ =~ /.css$/ ) {
				$mime = 'text/css';
			} else {
				$mime = '';
			}
			$assets{ "/" . $File::Find::name } = sub {
				my ( $httpd, $req ) = @_;

				$req->respond( { content => [ $mime, $content ] } );
			}
		},
		'assets/'
	);
	return %assets;
}

sub openBrowser {

	#Do nothing
	return 1;
}

1;
