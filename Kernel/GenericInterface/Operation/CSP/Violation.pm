# --
# Copyright (C) 2023 Niklas Schmitt, https://niklas-schmitt.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::GenericInterface::Operation::CSP::Violation;

use strict;
use warnings;
use utf8;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::Log',
);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    for my $Needed (qw( DebuggerObject WebserviceID )) {
        if ( !$Param{$Needed} ) {
            return {
                Success      => 0,
                ErrorMessage => "Got no $Needed!"
            };
        }

        $Self->{$Needed} = $Param{$Needed};
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');

    my $Result;
    my $Report = $Param{Data}->{Report};

    return {
        Success      => 0,
        ErrorMessage => "No valid Content-Security-Policy Report!"
    } if !$Report;

    my $Violated = $Report->{'effective-directive'};
    my $Blocked  = $Report->{'blocked-uri'};
    my $Document = $Report->{'document-uri'};
    my $Referrer = $Report->{'referrer'};

    my $Numbers = "-";
    if ( $Report->{'source-file'} && $Report->{'line-number'} && $Report->{'column-number'} ) {
        $Numbers = "- source-file: "
            . $Report->{'source-file'}
            . ", line: "
            . $Report->{'column-number'}
            . ", column: "
            . $Report->{'column-number'} . " -";
    }

    my $LogEntry
        = "Content-Security-Policy Violation: effective-directive: $Violated - blocked-uri: $Blocked $Numbers document-uri: $Document - referrer: $Referrer";

    $Self->EnhancedLogging(
        Level   => 'info',
        Message => $LogEntry,
        Data    => {},
    );

    $Result = {
        Success => 1,
        Data    => {
            Success => 1,
        },
    };

    return $Result;
}

# # combined logging for the generic interface and default Znuny log
sub EnhancedLogging {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');

    if ( $Self->{DebuggerObject} ) {
        $Self->{DebuggerObject}->DebugLog(
            DebugLevel => $Param{Level},
            Summary    => $Param{Message},
            Data       => $Param{Data},
        );
    }

    $LogObject->Log(
        Priority => $Param{Level},
        Message  => $Param{Message},
    );

    return 1;
}

1;
