use strict;
use warnings;
use utf8;
use Encode 'decode';
use Encode 'encode';
use open ":utf8";
use Config::Tiny;

#GetSiri
$ARGV[0] = decode('UTF-8', $ARGV[0]);
my $siri = $ARGV[0];

#LoadConfig
my $Config = Config::Tiny->new;
$Config = Config::Tiny->read( 'datalog.conf' );
my $cooltog = $Config->{_}->{cooltog};
my $coolvalue = $Config->{_}->{coolvalue};

#Response
#電気ON
if ($siri =~ /(電気|ライト)(を|)(つけて|ONにして)|部屋..(少し|ちょっと|かなり|)暗い(..す|よ|な|)/) {
	print "かしこまりました、部屋の電気をつけますね \n";
	my $result = `./post_reibo.sh > /dev/null &`;
#電気OFF
} elsif ($siri =~ /(電気|ライト)(を|)(消して|OFFにして)|部屋..(少し|ちょっと|かなり|)明るい(..す|よ|な|)/) {
	print "かしこまりました、部屋の電気を消しますね \n";
	my $result = `./post_reibo.sh > /dev/null &`;
#電気OFF
} elsif ($siri =~ /おやすみ(なさい|)/) {
	print "はい、おやすみなさい \n";
	my $result = `./post_reibo.sh > /dev/null &`;
#冷房ON
} elsif ($siri =~ /(冷房|クーラー|エアコン)(を|)つけて/) {
	if ($cooltog == 1) {
		print "すでに冷房は入っていますが、念のためもう一度送信しますね \n";
		my $result = `arduino_ir_remote -write cool$coolvalue > /dev/null &`;
	} elsif ($cooltog == 0) {
		print "かしこまりました、冷房を" . $coolvalue . "度で入れますね \n";
		my $result = `arduino_ir_remote -write cool$coolvalue > /dev/null &`;
		$Config->{_}->{cooltog} = 1;
		$Config->write( 'datalog.conf' );
	}
#冷房ON,調整
} elsif ($siri =~ /(少し|ちょっと|かなり|)暑い(..す|よ|)/) {
	if ($cooltog == 1) {

		my $cooldown = $coolvalue;
		$cooldown--;

		print "かしこまりました、冷房を" . $coolvalue . "度から" . $cooldown . "度に下げますね \n";

		$Config->{_}->{coolvalue} = $cooldown;
		$Config->write( 'datalog.conf' );

		my $result = `arduino_ir_remote -write cool$cooldown > /dev/null &`;
	} elsif ($cooltog == 0) {
		print "かしこまりました、冷房を" . $coolvalue . "度で入れますね \n";
		$Config->{_}->{cooltog} = 1;
		$Config->write( 'datalog.conf' );
		my $result = `arduino_ir_remote -write cool$coolvalue > /dev/null &`;
	} else {
		print "ERROR cooltogの値が正しくありません \n";
	}

} elsif ($siri =~ /(少し|ちょっと|かなり|)寒い(..す|よ|)/) {
	if ($cooltog == 1) {

		my $cooldown = $coolvalue;
		$coolup;

		print "かしこまりました、冷房を" . $coolvalue . "度から" . $coolup . "度に下げますね \n";

		$Config->{_}->{coolvalue} = $coolup;
		$Config->write( 'datalog.conf' );

		my $result = `arduino_ir_remote -write cool$coolup > /dev/null &`;
	} elsif ($cooltog == 0) {
		print "かしこまりました、冷房を" . $coolvalue . "度で入れますね \n";
		$Config->{_}->{cooltog} = 1;
		$Config->write( 'datalog.conf' );
		my $result = `arduino_ir_remote -write cool$coolvalue > /dev/null &`;
	} else {
		print "ERROR cooltogの値が正しくありません \n";
	}
#冷房ON,調整
} elsif ($siri =~ /(冷房|クーラー|エアコン)を(1[8-9]|2[0-9]|30)度に設定して/) {
	if ($cooltog == 1) {
		print "かしこまりました、冷房を" . $2 . "度に変更しますね \n";
		my $result = `arduino_ir_remote -write cool$2 > /dev/null &`;
	} elsif ($cooltog == 0) {
		print "かしこまりました、冷房を" . $2 . "度で入れますね";
		$Config->{_}->{cooltog} = 1;
		$Config->write( 'datalog.conf' );
		my $result = `arduino_ir_remote -write cool$2 > /dev/null &`;
	} else {
		print "ERROR cooltogの値が正しくありません \n";
	}

}
