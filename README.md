# NiklasSchmitt-CSPViolation
Znuny package to collect Content-Security-Policy violations via webservice


Config:
```
    <Setting Name="GenericInterface::Operation::Module###NiklasSchmitt::CSPViolation" Required="0" Valid="1">
        <Description Translatable="1">GenericInterface module registration for the operation layer.</Description>
        <Navigation>GenericInterface::Operation::ModuleRegistration</Navigation>
        <Value>
            <Hash>
                <Item Key="Name">CSPViolation</Item>
                <Item Key="Controller">NiklasSchmitt</Item>
                <Item Key="ConfigDialog">AdminGenericInterfaceOperationDefault</Item>
            </Hash>
        </Value>
    </Setting>
```

webservice:
```
---
Debugger:
  DebugThreshold: debug
  TestMode: '0'
Description: Content-Security-Policy
FrameworkVersion: 6.5.x
Provider:
  Operation:
    Violation:
      Description: CSP-Violation
      IncludeTicketData: '0'
      MappingInbound:
        Config:
          KeyMapDefault:
            MapTo: ''
            MapType: Keep
          ValueMapDefault:
            MapTo: ''
            MapType: Keep
        Type: Simple
      MappingOutbound:
        Type: Simple
      Type: NiklasSchmitt::CSPViolation
  Transport:
    Config:
      AdditionalHeaders: ~
      KeepAlive: ''
      MaxLength: '4096'
      RouteOperationMapping:
        Violation:
          ParserBackend: JSON
          RequestMethod:
          - GET
          - POST
          Route: /Violation
    Type: HTTP::REST
RemoteSystem: ''
Requester:
  Transport:
    Type: ''
```



```
Kernel/GenericInterface/Operation/NiklasSchmitt/CSPViolation.pm
# --
# Copyright (C) 2023 Niklas Schmitt, https://niklas-schmitt.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::GenericInterface::Operation::NiklasSchmitt::CSPViolation;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

use parent qw(Kernel::GenericInterface::Operation::Common);

our $ObjectManagerDisabled = 1;

=head1 NAME

Kernel::GenericInterface::Operation::NiklasSchmitt::CSPViolation

=head1 PUBLIC INTERFACE

=head2 new()

usually, you want to create an instance of this
by using Kernel::GenericInterface::Operation->new();

=cut

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

=head2 Run()

Receive Violations of Content-Security-Policy.
=cut

sub Run {
    my ( $Self, %Param ) = @_;

    my $Result;

use Data::Dumper;
print STDERR 'Debug Dump - ModuleName - %Param = ' . Dumper(\%Param) . "\n";

    $Result = {
        Success => 1,
        Data    => {
            Success => 1,
        },
    };

    return $Result;
}

# # combined logging for the generic interface and default Znuny log
# sub EnhancedLogging {
#     my ( $Self, %Param ) = @_;

#     my $LogObject = $Kernel::OM->Get('Kernel::System::Log');

#     if ( $Self->{DebuggerObject} ) {
#         $Self->{DebuggerObject}->DebugLog(
#             DebugLevel => $Param{Level},
#             Summary    => $Param{Message},
#             Data       => $Param{Data}
#         );
#     }

#     # if the web service ID is present, add it as a log prefix, so the admin knows what's up
#     if ( $Self->{WebserviceID} ) {
#         $Param{Message} = "Web service ID '$Self->{WebserviceID}': $Param{Message}";
#     }

#     $LogObject->Log(
#         Priority => $Param{Level},
#         Message  => $Param{Message}
#     );

#     return 1;
# }

1;

```
