# --
# Copyright (C) 2023 Niklas Schmitt, https://niklas-schmitt.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_NiklasSchmittCSPViolation;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # SysConfig
    $Self->{Translation}->{'Autoloading of NiklasSchmittCSPViolation extension.'} = 'Autoloading für das Modul NiklasSchmittCSPViolation.';

    return 1;
}

1;
