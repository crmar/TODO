package TODO::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use DBI;

filter 'set_title' => sub {
    my $app = shift;
    sub {
        my ( $self, $c )  = @_;
        $c->stash->{site_name} = __PACKAGE__;
        $app->($self,$c);
    }
};


get '/json' => sub {
    my ( $self, $c )  = @_;
    my $result = $c->req->validator([
        'q' => {
            default => 'Hello',
            rule => [
                [['CHOICE',qw/Hello Bye/],'Hello or Bye']
            ],
        }
    ]);
    $c->render_json({ greeting => $result->valid->get('q') });
};


sub dbh {
	my $user = 'myusr';
	my $pass = '12345';
	DBI->connect('DBI:mysql:basic', $user, $pass);
}


post '/input' => sub {
	my ( $self, $c ) = @_;
	my $td = $c->req->parameters_raw->{td};
	my $dl = $c->req->parameters_raw->{dl};
	my $dbh = $self->dbh([$self]);
	my $sth = $dbh->prepare("insert into todo (todo, date) values ('$td', '$dl')");
	$sth->execute;
	$sth->finish;
	$dbh->disconnect;
$c->redirect('/');
};


get '/' => [qw/set_title/] => sub {
	my ( $self, $c ) = @_;
	my $dbh = $self->dbh([$self]);
	my $sth = $dbh->prepare("select * from todo order by date");
	$sth->execute;
	my $row = $sth->fetchall_arrayref();
	
	
	#while(my $row = $sth->fetch()){
	#	my ($fno, $fid) = @$row;
	#	$table_content .= "$fno : $fid\n";
	#}
	$sth->finish;
	$dbh->disconnect;
	
$c->render('index.tx', { greeting => "Hello", rows => $row });
};


get '/delete' => [qw/set_title/] => sub {
	my ( $self, $c ) = @_;
	my $id = $c->req->parameters_raw->{id};
	my $dbh = $self->dbh([$self]);
	my $sth = $dbh->prepare("delete from todo where No=$id");
	$sth->execute;
	$sth->finish;
	$dbh->disconnect;
	
$c->redirect('/');
};


post '/change' => sub {
	my ( $self, $c ) = @_;
	my $changetd = $c->req->parameters_raw->{changetd};
	my $changedl = $c->req->parameters_raw->{changedl};
	my $id = $c->req->parameters_raw->{id};
	my $dbh = $self->dbh([$self]);
	my $sth = $dbh->prepare("update todo set todo='$changetd', date='$changedl' where No=$id");
	$sth->execute;
	$sth->finish;
	$dbh->disconnect;
$c->redirect('/');
};





1;


