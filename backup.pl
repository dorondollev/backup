#!/usr/bin/perl -w

use DBI();
use Fcntl 'LOCK_EX', 'LOCK_UN';


($client, $schedule) = @ARGV;

$dow = getTime('dow'); # day of week
$month = getTime('month'); # current month
$dom = getTime('dom'); # day of month
$hour = getTime('hour'); # current hour
$minute = getTime('minute'); # current minute
$year = getTime('year'); # current year

$currentTime = $dow . " " . $dom . " " . $month . " " . $year . " " . $hour . ":" . $minute;
print "Start of backup $client $schedule at $currentTime\n";
print "My process is: $$\n";

if ($client eq "" || $schedule eq "")
{
	print "Usage $0 client schedule\n";
   	exit 1;
}

$to = 'doron';
$from = 'root';
@subject = "backup of $client $schedule finished"; $logFile = "/var/log/syslog.dated/current/backup.log";
open(my $log, '>>', $logFile) or die "Could not open file $logFile: $!";

my $dbh = DBI->connect("DBI:mysql:database=backup;host=localhost",
         "mysqladmin", "manager11",
         {'RaiseError' => 1});

my $sth = $dbh->prepare("SELECT * FROM commands where client=\"$client\" and schedule=\"$schedule\"");
if (!$sth)
{
	die "Error:" . $dbh->errstr . "\n";
}

$sth->execute();

if (!$sth->execute)
{ die "Error:" . $sth->errstr . "\n"; }

for ($i=0; $ref = $sth->fetchrow_hashref(); $i++)
{
	$id[$i] = $ref->{'id'};
    	$client[$i] = $ref->{'client'};
	$source_path[$i] = $ref->{'source_path'};
	#$target_path[$i] = $ref->{'target_path'};
    	$command[$i] = $ref->{'command'};
    	$backup_type[$i] = $ref->{'backup_type'};
    	$file_type[$i] = $ref->{'file_type'};
    	$enable[$i] = $ref->{'enable'};
    	$dbh->do("update commands set active=1 where id=$id[$i]");
}
$sth->finish();
$dbh->disconnect();

pipe(READ, WRITE);
$| = 1;
$PIDFILE = "/var/run/backup.pid";
chkIfProcExist($PIDFILE);

for($i=$#command; $i >= 0 && ($pid=fork);$i--){;} if ($pid == 0) 
{
	close READ;
    	chomp $id[$i];
    	print $log "Backup saveset id: $id[$i] $$\n";

    	@dateString = getDate();
	print "dateString<@dateString>\n";
	if($source_path[$i] eq "/")
	{
		$myPath = "root";
	}
	else
	{
		my @line = split(/\//, $source_path[$i]);
		shift @line;
		$myPath = join("_", @line);
	}
	print "myPath<$myPath>\n";
	
	@backupFileVars = ($client[$i], $schedule, $myPath, @dateString, $file_type[$i]); 
	$backupFileName = join (".", @backupFileVars);
	print "backupFileName<$backupFileName>\n";
    	$myLog = "/var/log/syslog.dated/current/$client[$i].$schedule.$myPath.$id[$i].log";
	print "myLog<$myLog>\n";
	my @lines;	 
    	if ($enable[$i] == 0)
    	{
        	print WRITE "$$: $command[$i] is not enabled\n";
        	print "$$: $command[$i] is not enabled\n";
    	}
    	else
    	{
		my $dbh = DBI->connect("DBI:mysql:database=backup;host=localhost","mysqladmin", "manager11", {'RaiseError' => 1});
		if ($backup_type[$i] eq 'custom')
        	{
			$dbh->do("INSERT INTO state (date_start, time_start, backup_file_name, command_id) values (curdate(), now(), 'custom', $id[$i])");
			$backupCmd[$i] = $command[$i];
        	}
        	else
		{
			$dbh->do("INSERT INTO state (date_start, time_start, backup_file_name, command_id) 
				values (curdate(), now(), \"$backupFileName\", $id[$i])");
				
			@command_vars = ($command[$i], $backupFileName);
			$backupCmd[$i] = join("/", @command_vars);
		}
		$st_id[$i] = $dbh->last_insert_id( undef, undef, "state", undef );
        	$status[$i] = `$backupCmd[$i] >>$myLog`;
		print "status-i<$status[$i]>\n";
					
        	if ($status[$i])
        	{
            		print WRITE "$$: $command[$i] failed with exit status: $status[$i]\n";
            		print "$$: $command[$i] failed with exit status: $status[$i]\n";
        	}
        	else
        	{
			print WRITE "$$: $backupCmd[$i] finished successfully\n";
            		print "$$: $backupCmd[$i] finished successfully\n";
        	}
		$dbh->do("UPDATE state SET date_end=CURDATE(), time_end=CURTIME(), result=$status[$i] WHERE state_id=$st_id[$i]");
            	open (DATA, $myLog) or die $!;
            	while (<DATA>)
            	{
			chomp;
                	$_ =~ s/\n+/ /g;
                	push(@lines, $_);
			$dbh->do("update state set log_content=\"@lines\" where state_id=$st_id[$i]");
			#$dbh->do("update state set logfile=\"$myLog\" where state_id=$st_id[$i]");
            	}
            	close DATA;
        	$dbh->do("update commands set active=0 where id=$id[$i]"); ######## finish here the state row ########
    	}
    	$dbh->disconnect();
    	exit(0);
}
else
{
	for($i=$#command;$i >=0;$i--)
    	{
		wait();
    	}
    	$currentTime = getTime('dom') . "-" . getTime('month') . "-" . getTime('year') . " " . getTime('hour') . ":" . getTime('dom');
    	print WRITE "End of backup $client $schedule at $currentTime\n";
    	print "End of backup $client $schedule at $currentTime\n";
    	close WRITE;
    	unlink($PIDFILE);
    	open(MAIL, "|/usr/sbin/sendmail -t");
    	print MAIL "To: $to\n";
    	print MAIL "From: $from\n";
    	print MAIL "Subject: @subject\n\n";
    	while (<READ>)
    	{
		print MAIL "$_\n";
    	}
}
system("cat /dev/null >$PIDFILE");
close $log;
close MAIL;
#close LOG;

sub getDate
{
	return getTime('dow') . "." . getTime('month') . "." . getTime('dom') . "." . getTime('hour') . "_" . getTime('minute') . "." . getTime('year');
}

sub getTime
{
	$timeRequest = shift;
    	@months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    	@weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
    	#($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
    	@localtime = localtime();
    	$year = 1900 + $localtime[5];
    	if ($timeRequest eq 'hour')
    	{
		return $localtime[2];
    	}
    	elsif ($timeRequest eq 'minute')
    	{
		return $localtime[1];
    	}
    	elsif ($timeRequest eq 'second')
    	{
		return $localtime[0];
    	}
    	elsif ($timeRequest eq 'dow')
    	{
		return $weekDays[$localtime[6]];
    	}
    	elsif ($timeRequest eq 'month')
    	{
		return $months[$localtime[4]];
    	}
    	elsif ($timeRequest eq 'dom')
    	{
		return $localtime[3];
    	}
    	elsif ($timeRequest eq 'year')
    	{
		return $year;
    	}
}

sub chkIfProcExist
{
	$PIDFILE=shift;
    	if (-s $PIDFILE)
    	{
		open(PIDFILE);
        	$PID=<PIDFILE>;
		chomp $PID;
        	close(PIDFILE);
        	print "backup.pid content:<$PID>\n";
        	while($PID > 0)
        	{
			open(PIDFILE);
            		$PID=<PIDFILE>;
            		close(PIDFILE);
            		chomp $PID;
            		print "PID: $PID\n";
            		`ps -p $PID > /dev/null 2>&1`;
            		$exit = $?;
            		print "exit: $exit\n";
            		if($exit == 0)
            		{
				print "sleeping...";
                		sleep 30;
            		}
            		else
            		{
				print "Process $PID is gone\n";
                		$PID = 0;
            		}
        	}
    	}
    	open(RUN, ">$PIDFILE") or die "Can't open $PIDFILE for write: $!\n";
    	print RUN $$;
    	close RUN;
}
