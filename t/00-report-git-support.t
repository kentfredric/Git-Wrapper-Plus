use strict;
use warnings;

use Test::More;

# ABSTRACT: Report supported features of your git

use Git::Wrapper::Plus::Tester;
use Git::Wrapper::Plus::Support;

my $t = Git::Wrapper::Plus::Tester->new();
my $s = Git::Wrapper::Plus::Support->new( git => $t->git );

my $data = {
  commands   => {},
  behaviours => {},
};

$t->run_env(
  sub {
    subtest 'commands' => sub {
      note "\nCommands:";
      for my $command ( sort keys %{$Git::Wrapper::Plus::Support::command_db} ) {
        my $msg = '- ' . $command . ' ';
        if ( $s->supports_command($command) ) {
          $msg .= "supported";
          push @{ $data->{commands}->{supported} }, $command;
        }
        else {
          push @{ $data->{commands}->{unsupported} }, $command;
          $msg .= "UNSUPPORTED";
        }
        note $msg;

      }
      pass("Commands reporting ok");
    };
    subtest 'behaviours' => sub {
      note "\nBehaviours:";

      for my $behaviour ( sort keys %{$Git::Wrapper::Plus::Support::behaviour_db} ) {
        my $msg = '- ' . $behaviour . ' ';
        if ( $s->supports_behaviour($behaviour) ) {
          $msg .= "supported";
          push @{ $data->{behaviours}->{supported} }, $behaviour;
        }
        else {
          push @{ $data->{behaviours}->{unsupported} }, $behaviour;
          $msg .= "UNSUPPORTED";
        }
        note $msg;
      }
      pass("Behaviours reporting ok");

    };
  }
);

diag "\n";
for my $level ( sort keys %{$data} ) {
  for my $grade ( sort keys %{ $data->{$level} } ) {
    my $prefix = sprintf "%14s %-11s", $level, $grade;
    my @all = @{ $data->{$level}->{$grade} };
    my @this;
    while (@all) {
      push @this, shift @all;
      my $mesg = "$prefix | " . ( join q[, ], @this );
      if ( length $mesg > 110 ) {
        diag $mesg;
        $prefix = sprintf "%14s %-11s", q[], q[];
        @this = ();
      }
      if ( not @all ) {
        diag $mesg if @this;
        last;
      }
    }

    #diag "$prefix | " . join q[, ], @{ $data->{$level}->{$grade} };
  }
}

done_testing;

