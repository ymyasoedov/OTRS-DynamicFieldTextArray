# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2020 Yuri Myasoedov <ymyasoedov@yandex.ru>
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::System::DynamicField::Driver::BaseArray;

use strict;
use warnings;

use parent qw(Kernel::System::DynamicField::Driver::Base);

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::DynamicFieldValue',
    'Kernel::System::Log',
);

=head1 NAME

Kernel::System::DynamicField::Driver::BaseArray - common fields backend functions

=head1 PUBLIC INTERFACE

=cut

sub ValueIsDifferent {
    my ( $Self, %Param ) = @_;

    # special cases where the values are different but they should be reported as equals
    return if !defined $Param{Value1} && ( defined $Param{Value2} && $Param{Value2} eq '' );
    return if !defined $Param{Value2} && ( defined $Param{Value1} && $Param{Value1} eq '' );

    # this method can check ordered and unordered arrays,
    # for unordered arrays we have to sort them before checking
    if ( ref $Param{Value1} eq 'ARRAY' && ref $Param{Value2} eq 'ARRAY' ) {
        if ( !$Self->{Ordered} ) {
            my @Value1 = sort @{ $Param{Value1} };
            my @Value2 = sort @{ $Param{Value2} };
            return DataIsDifferent(
                Data1 => \@Value1,
                Data2 => \@Value2,
            );
        }
    }

    # compare the results
    return DataIsDifferent(
        Data1 => \$Param{Value1},
        Data2 => \$Param{Value2}
    );
}

sub SearchFieldPreferences {
    my ( $Self, %Param ) = @_;

    my @Preferences = (
        {
            Type        => '',
            LabelSuffix => '',
        },
    );

    return \@Preferences;
}

=head2 ValueSearch()

Searches/fetches dynamic field value.

    my $Value = $BackendObject->ValueSearch(
        DynamicFieldConfig => $DynamicFieldConfig,      # complete config of the DynamicField
        Search             => 'test',
    );

    Returns [
        {
            ID            => 437,
            FieldID       => 23,
            ObjectID      => 133,
            ValueText     => 'some text',
            ValueDateTime => '1977-12-12 12:00:00',
            ValueInt      => 123,
        },
    ];

=cut

sub ValueSearch {
    my ( $Self, %Param ) = @_;

    # check mandatory parameters
    if ( !IsHashRefWithData( $Param{DynamicFieldConfig} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need DynamicFieldConfig!"
        );
        return;
    }

    my $SearchTerm = $Param{Search};
    my $Operator   = 'Contains';
=for
    if ( $Self->HasBehavior( Behavior => 'IsLikeOperatorCapable' ) ) {
        $SearchTerm = '%' . $Param{Search} . '%';
        $Operator   = 'Like';
    }
=cut

    my $SearchSQL = $Self->SearchSQLGet(
        DynamicFieldConfig => $Param{DynamicFieldConfig},
        TableAlias         => 'dynamic_field_value',
        SearchTerm         => $SearchTerm,
        Operator           => $Operator,
    );

    if ( !defined $SearchSQL || !length $SearchSQL ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Error generating search SQL!"
        );
        return;
    }

    my $Values = $Kernel::OM->Get('Kernel::System::DynamicFieldValue')->ValueSearch(
        FieldID   => $Param{DynamicFieldConfig}->{ID},
        Search    => $Param{Search},
        SearchSQL => $SearchSQL,
    );

    return $Values;
}

1;

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<https://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (GPL). If you
did not receive this file, see L<https://www.gnu.org/licenses/gpl-3.0.txt>.

=cut
