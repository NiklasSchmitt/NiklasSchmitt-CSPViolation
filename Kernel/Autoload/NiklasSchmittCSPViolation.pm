# --
# Copyright (C) 2023 Niklas Schmitt, https://niklas-schmitt.de
# --
# $origin: Znuny - a20eddf94b64dc30ecf92910fb7bc4b16c4cf612 - Kernel/Output/HTML/Layout.pm
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

## nofilter(TidyAll::Plugin::Znuny::Perl::LayoutObject)

use Kernel::Output::HTML::Layout;

package Kernel::Output::HTML::Layout;    ## no critic

use strict;
use warnings;
use utf8;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Encode',
    'Kernel::System::Log',
);

# disable redefine warnings in this scope
{
    no warnings 'redefine';    ## no critic

    # backup original Attachment()
    my $Attachment = \&Kernel::Output::HTML::Layout::Attachment;

    # redefine Attachment() of Kernel::Modules::PublicFAQZoom::Attachment
    *Kernel::Output::HTML::Layout::Attachment = sub {
        my ( $Self, %Param ) = @_;

        # check needed params
        for my $Needed (qw(Content ContentType)) {
            if ( !defined $Param{$Needed} ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Got no $Needed!",
                );
                $Self->FatalError();
            }
        }

        # get config object
        my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

        # return attachment
        my $Output = 'Content-Disposition: ';
        if ( $Param{Type} ) {
            $Output .= $Param{Type};
            $Output .= '; ';
        }
        else {
            $Output .= $ConfigObject->Get('AttachmentDownloadType') || 'attachment';
            $Output .= '; ';
        }

        if ( $Param{Filename} ) {

            # IE 10+ supports this
            my $URLEncodedFilename = URI::Escape::uri_escape_utf8( $Param{Filename} );
            $Output .= " filename=\"$Param{Filename}\"; filename*=utf-8''$URLEncodedFilename";
        }
        $Output .= "\n";

        # get attachment size
        $Param{Size} = bytes::length( $Param{Content} );

        # add no cache headers
        if ( $Param{NoCache} ) {
            $Output .= "Expires: Tue, 1 Jan 1980 12:00:00 GMT\n";
            $Output .= "Cache-Control: no-cache\n";
            $Output .= "Pragma: no-cache\n";
        }
        $Output .= "Content-Length: $Param{Size}\n";
        $Output .= "X-UA-Compatible: IE=edge,chrome=1\n";

        if ( !$ConfigObject->Get('DisableIFrameOriginRestricted') ) {
            $Output .= "X-Frame-Options: SAMEORIGIN\n";
        }

        if ( $Param{Sandbox} && !$Kernel::OM->Get('Kernel::Config')->Get('DisableContentSecurityPolicy') ) {

         # Disallow external and inline scripts, active content, frames, but keep allowing inline styles
         #   as this is a common use case in emails.
         # Also disallow referrer headers to prevent referrer leaks via old-style policy directive. Please note this has
         #   been deprecated and will be removed in future OTRS versions in favor of a separate header (see below).
         # img-src:    allow external and inline (data:) images
         # script-src: block all scripts
         # object-src: allow 'self' so that the browser can load plugins for PDF display
         # frame-src:  block all frames
         # style-src:  allow inline styles for nice email display
         # referrer:   don't send referrers to prevent referrer-leak attacks

# ---
# NiklasSchmitt-CSPViolation
# ---
#            $Output
#                .= "Content-Security-Policy: default-src *; img-src * data:; script-src 'none'; object-src 'self'; frame-src 'none'; style-src 'unsafe-inline'; referrer no-referrer;\n";
# ---
#
            $Output
                .= "Content-Security-Policy: default-src *; img-src * data:; script-src 'none'; object-src 'self'; frame-src 'none'; style-src 'unsafe-inline'; report-uri nph-genericinterface.pl/Webservice/ContentSecurityPolicy/Violation;\n";

# ---

            # Use Referrer-Policy header to suppress referrer information in modern browsers
            #   (to prevent referrer-leak attacks).
            $Output .= "Referrer-Policy: no-referrer\n";
        }

        if ( $Param{AdditionalHeader} ) {
            $Output .= $Param{AdditionalHeader} . "\n";
        }

        if ( $Param{Charset} ) {
            $Output .= "Content-Type: $Param{ContentType}; charset=$Param{Charset};\n\n";
        }
        else {
            $Output .= "Content-Type: $Param{ContentType}\n\n";
        }

        # disable utf8 flag, to write binary to output
        my $EncodeObject = $Kernel::OM->Get('Kernel::System::Encode');
        $EncodeObject->EncodeOutput( \$Output );
        $EncodeObject->EncodeOutput( \$Param{Content} );

        # fix for firefox HEAD problem
        if ( !$ENV{REQUEST_METHOD} || $ENV{REQUEST_METHOD} ne 'HEAD' ) {
            $Output .= $Param{Content};
        }

        # reset binmode, don't use utf8
        binmode STDOUT, ':bytes';

        return $Output;
    }
}

1;
