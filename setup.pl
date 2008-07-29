#! /usr/bin/perl
# setupscript
# setupscript for the exciting code
print "---------------------------------------------------------\n";

opendir(PDIR, "build/platforms") || die("Cannot open directory");
@makeincfiles= readdir(PDIR);
$count=1;
foreach $file (@makeincfiles){
 	$platform="";
	if($file=~ m/make\.inc\.(.+$)/) 
	{ $platform=$1;
	   print $count." ".$platform;
	   print ("\n");
	   $count++;
	push(@fileslist,$file);
	   if ($count>10) {
		   print "type enter for more";
		   $wait=<>;
	   }
	}
}
print "\n enter the number of the plattform that suites your system best:\n";
$sel=<>;

if ($sel>$count-1 || $sel<1 || $sel=~m/^$/ || $sel!~m/^\d+$/) {
	print "\ntry again\n\n";
	exit;
}

$filename="build/platforms/" . @fileslist[$sel];

@args=("cp",$filename,"build/make.inc");
$return= system(@args);

$selected=0;
while($selected==0){
	print "\nIf you have mpi installed you can build exciting with k-point parallelization support.\n\n";
	print "build MPI binary (yes/No)\n";
	$MPI=<>;
	if($MPI=~m/yes/){
		$selected=1;
		system("echo \"BUILDMPI=true\">>build/make.inc");
	}elsif($MPI=~m/no/) {
		system("echo \"BUILDMPI=false\">>build/make.inc");
		$selected=1;
	}else{
		print "please chose yes or no";
		$selected=0;
	}
}

$selected=0;
while($selected==0){
print "\nIf you have multithreaded BLAS/LAPACK installed you can build exciting with smp support.\n\n";
print "build SMP lib binary (yes/No)\n";
$SMP=<>;
if($SMP=~m/yes/){
	system("echo \"BUILDSMP=true\">>build/make.inc");
		$selected=1;
}elsif ($SMP=~m/no/)
{
	system("echo \"BUILDSMP=false\" >>build/make.inc");
		$selected=1;
}else{
	print "please chose yes or no";
		
}
}

