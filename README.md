:construction_worker: **!!WARNING!!** **This code is under development and is not ready for production use. You can use it on your own risk. I will appreciate on any help.**

# OTRS-DynamicFieldTextArray
OTRS package that adds a text array type of dynamic fields

# Searching objects by array items

Let's assume, that for the Ticket object dynamic field TextArrayField has been created. So, you can search tickets containing specified string:

```perl
my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldGet(
    Name => 'TextArrayField',
);

my @TicketIDs = $Kernel::OM->Get('Kernel::System::Ticket')->TicketSearch(
    Result => 'ARRAY',
    DynamicField_TextListExample => {
        Contains => 'foo',
    },
    UserID => 1,
);
```

You can specify an array of strings, if you want to find tickets, that contain at least one of the specified strings:

```perl
@TicketIDs = $Kernel::OM->Get('Kernel::System::Ticket')->TicketSearch(
    Result => 'ARRAY',
    DynamicField_TextListExample => {
        Contains => [ 'foo', 'bar' ],
    },
    UserID => 1,
);
```
