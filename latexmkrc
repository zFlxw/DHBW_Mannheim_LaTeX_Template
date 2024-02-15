@default_files = ("dokumentation.tex");

$out_dir = "output";    # set the output directory
$pdf_mode = 1;          # enable pdf output with pdflatex or similar
$dvi_mode = 0;          # disable dvi output
$ps_mode = 0;           # disable PostScript(PS) output
$recorder = 1;          # enable -recorder option to generate .fls file
$bibtex_use = 2;        # remove .bbl from output on clean

# remove all temporary files which are not removed automatically from output on clean
@generated_exts = qw(fls lof lot toc glg glo gls ist lol log run.xml synctex.gz);

# handle glossaries and glossaries-extra
add_cus_dep( 'acn', 'acr', 0, 'makeglossaries' );
add_cus_dep( 'glo', 'gls', 0, 'makeglossaries' );
$clean_ext .= " acr acn alg glo gls glg";

sub makeglossaries {
    my ($base_name, $path) = fileparse( $_[0] );
    my @args = ( "-d", $path, $base_name );
    if ($silent) { unshift @args, "-q"; }
    return system "makeglossaries", @args;
}

# %D: input directory
# %O: output directory
# %S: source file
$pdflatex = 'internal mypdflatex %D %O %S';

# custom pdflatex function to move the pdf and synctex.gz file
# from the output directory to the main directory
sub mypdflatex {
  use File::Copy qw(move);

  my $file = shift;
  my ($base_name, $path) = fileparse( $file );
  my $synctexfile = $path . ($base_name =~ s/\.[^.]+$//r) . ".synctex.gz";
  my $new_dir = $path . "../";
  my @args = @_;
  unshift(@args, "-synctex=1");

  $return = system 'pdflatex', @args;

  move $file, $new_dir;
  move $synctexfile, $new_dir;

  return $return;
}