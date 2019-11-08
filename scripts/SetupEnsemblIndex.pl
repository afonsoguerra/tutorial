
#Check for latest versions

system("wget --spider --no-remove-listing -q ftp://ftp.ensembl.org/pub/");
my $latestReleases = ` cat .listing | grep release | tail -n 3 | rev | cut -b -24 | rev`;
system("rm -rf .listing");


print STDERR "\n\nWelcome to the script to download and index Ensembl genomes\n\n";

print STDERR "The latest Ensembl versions are :\n".$latestReleases."\n\n";


my @tmp = split("\n", $latestReleases);
my $latest = "NA";
$latest = $1 if($tmp[-1]=~ m/release-(\d+)/);

#Ask about version
my $ensVer = &promptUser("What is the Ensembl version you want to download? ", $latest);

#Ask about species

my $ensSP = &promptUser("What is the Ensembl species you want to download?\nLikely choices are \"homo_sapiens\" or \"danio_rerio\"\nThe default is ", "homo_sapiens");



print STDERR "Downloading Transcriptome file, please wait ...\n\n";

#Download file
system("wget --no-parent --no-remove-listing -O ../Data/Ensembl-${ensSP}-${ensVer}-cdna.fa.gz ftp://ftp.ensembl.org/pub/release-${ensVer}/fasta/${ensSP}/cdna/*.all.fa.gz");
#ftp://ftp.ensembl.org/pub/release-98/fasta/danio_rerio/cdna/



#Setup kallisto index run and set it going




sub promptUser {


   local($promptString,$defaultValue) = @_;

   if ($defaultValue) {
      print $promptString, "[", $defaultValue, "]: ";
   } else {
      print $promptString, ": ";
   }

   $| = 1;               # force a flush after our print
   $_ = <STDIN>;         # get the input from STDIN (presumably the keyboard)

   chomp;


   if ("$defaultValue") {
      return $_ ? $_ : $defaultValue;    # return $_ if it has a value
   } else {
      return $_;
   }
}

