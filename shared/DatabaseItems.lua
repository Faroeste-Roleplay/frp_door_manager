--[[
door {
    handle 'door_left_ilev_247',

    door_hash '3746429585',

    state 'UNLOCKED',

    pair 'door_right_ilev_247_',

    
        isLockpickable {
            time = 1000,
            autoRelocksInSeconds = 1,
            
        }
        locksAtNight 'true'
    
}


commerce_door {
    handle 'door_right_ilev_247_',
    model 'v_ilev_247door_r',
    position { 2559.304, 386.6865, 108.7729 },
    state 'UNLOCKED',
    pair 'door_left_ilev_247',
}
garage_door {
    handle('garage_door_fast_lane'),
    model '-983965772',
    position { 945.9343, -985.5709, 41.1689 },
    state 'LOCKED',
    allowed_groups{ 'tuner_carshop', 'car_shop' },
}
]]

-- door {
--     handle 'door_house_01_main',

--     door_hash '3268076220',

--     allowed_groups { 'admin' },

--     state 'LOCKED',

-- }

door {
    handle 'door_blackwater_inside_room',

    door_hash '2817192481',

    state 'LOCKED',
    
    allowed_groups{ 'admin', 'superadmin' }
}

door {
    handle 'door_blackwater_front',

    door_hash '531022111',

    state 'UNLOCKED',

    -- allowed_groups{ 'admin', 'superadmin'}
}

door {
    handle 'door_valentine_hotel',

    door_hash '3765902977',

    state 'LOCKED',

    allowed_groups{ 'admin', 'superadmin'}
}


door {
    handle 'door_valentine_bank_01',
    door_hash'2642457609',
    allowed_groups {'admin'},
    state 'UNLOCKED',
    pair 'door_valentine_bank_02'
}
door {
    handle 'door_valentine_bank_02',
    door_hash'3886827663',
    allowed_groups {'admin'},
    state 'UNLOCKED',
    pair 'door_valentine_bank_01'
}


door {
    handle 'door_rhodes_bank_01',
    door_hash'3088209306',
    allowed_groups {'admin'},
    state 'UNLOCKED',
    pair 'door_rhodes_bank_02'
}
door {
    handle 'door_rhodes_bank_02',
    door_hash'3317756151',
    allowed_groups {'admin'},
    state 'UNLOCKED',
    pair 'door_rhodes_bank_01'
}


door {
    handle 'door_saint_dennis_bank_01',
    door_hash'2817024187',
    allowed_groups {'admin'},
    state 'UNLOCKED',
    pair 'door_saint_dennis_bank_02'
}
door {
    handle 'door_saint_dennis_bank_02',
    door_hash'2089945615',
    allowed_groups {'admin'},
    state 'UNLOCKED',
    pair 'door_saint_dennis_bank_01'
}

door {
    handle 'door_saint_dennis_bank_03',
    door_hash'2158285782',
    allowed_groups {'admin'},
    state 'UNLOCKED',
    pair 'door_saint_dennis_bank_04'
}
door {
    handle 'door_saint_dennis_bank_04',
    door_hash'1733501235',
    allowed_groups {'admin'},
    state 'UNLOCKED',
    pair 'door_saint_dennis_bank_03'
}


door {
    handle 'door_blackwater_inside_jail',
    door_hash '2117902999',
    state 'LOCKED',
    allowed_groups{ 'admin', 'superadmin'}
}

door {  
    door_hash '1508776842',
    allowed_groups {'law', 'police'},
    state 'LOCKED',
    handle 'door_valentine_jail_extern'
}
door {  
    door_hash '1988748538',
    allowed_groups {'law', 'police'},
    state 'LOCKED',
    handle 'door_valentine_1'
}
door {
    door_hash '395506985',
    allowed_groups {'law', 'police'},
    state 'LOCKED',
    handle 'door_valentine_2'
}
door {   
    door_hash '535323366',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_valentine_3'
}
door {
    door_hash '295355979',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_valentine_4'
}
door {
    door_hash'193903155',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_valentine_5'
}
door {
    door_hash'349074475',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_rhodes_6'
}
door {
    door_hash'1614494720',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_rhodes_7'
}
door {
    door_hash'1878514758',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_rhodes_8'
}
door {
    door_hash'1711767580',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_saint_denis_9'
}
door {
    door_hash'1995743734',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_saint_denis_10'
}
door {
    door_hash'2515591150',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_saint_denis_11'
}
door {
    door_hash'3365520707',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_saint_denis_12'
}
door {
    door_hash'2212368673',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_annesburg_13'
}
door {
    door_hash'1502928852',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_annesburg_14'
}
door {
    door_hash'1657401918',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_annesburg_15'
}
door {
    door_hash'902070893',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_strawberry_16'
}
door {
    door_hash'1207903970',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_strawberry_17'
}
door {
    door_hash'1821044729',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_strawberry_18_jail'
}
door {
    door_hash'2810801921',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_blackwater_18'
}
door {
    door_hash'2514996158',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_blackwater_19'
}
door {
    door_hash'2167775834',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_blackwater_20'
}
door {
    door_hash'3410720590',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_blackwater_jail_r_01',
    pair 'door_blackwater_jail_l_01'
}
door {
    door_hash'3821185084',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_blackwater_jail_l_01',
    pair 'door_blackwater_jail_r_01'
}
door {
    door_hash'2677989449',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_tumbleweed_22'
}
door {
    door_hash'2984805596',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_tumbleweed_23'
}
door {
    door_hash'4235597664',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_armadillo_24'
}
door {
    door_hash'4016307508',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_armadillo_25'
}
door {
    door_hash'66424668',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_armadillo_26'
}
door {
    door_hash'831345624',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_tumbleweed_27'
}
door {
    door_hash'2735269038',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_tumbleweed_28'
}
door {
    door_hash'2444845424',
    allowed_groups  {'law', 'police'},
    state 'LOCKED',
    handle 'door_tumbleweed_29'
}
door {
    door_hash'2212368673',
    allowed_groups {'law', 'police'},
    state 'LOCKED',
    handle 'ann_jail_main_door_01'
}

door {
    door_hash'417663242',
    allowed_groups {'law', 'police'},
    state 'LOCKED',
    handle 'door_saint_dennis_jail_entrance_01',
    pair 'door_saint_dennis_jail_entrance_02'
}
door {
    door_hash'1611175760',
    allowed_groups {'law', 'police'},
    state 'LOCKED',
    handle 'door_saint_dennis_jail_entrance_02',    
    pair 'door_saint_dennis_jail_entrance_01'
}

door {
    door_hash'1879655431',
    allowed_groups {'law', 'police'},
    state 'LOCKED',
    handle 'door_saint_dennis_jail_01',
    pair 'door_saint_dennis_jail_02'
}
door {
    door_hash'3124713594',
    allowed_groups {'law', 'police'},
    state 'LOCKED',
    handle 'door_saint_dennis_jail_02',    
    pair 'door_saint_dennis_jail_01'
}

door {
    door_hash'3430284519',
    allowed_groups {'law', 'police'},
    state 'LOCKED',
    handle 'door_saint_dennis_jail_03',
    pair 'door_saint_dennis_jail_04'
}
door {
    door_hash'3601535313',
    allowed_groups {'law', 'police'},
    state 'LOCKED',
    handle 'door_saint_dennis_jail_04',    
    pair 'door_saint_dennis_jail_03'
}

door {
    door_hash'1020479727',
    allowed_groups {'law', 'police'},
    state 'LOCKED',
    handle 'door_saint_dennis_jail_garage_01',
    pair 'door_saint_dennis_jail_garage_02'
}
door {
    door_hash'603068205',
    allowed_groups {'law', 'police'},
    state 'LOCKED',
    handle 'door_saint_dennis_jail_garage_02',    
    pair 'door_saint_dennis_jail_garage_01'
}

door {
    door_hash'305296302',
    allowed_groups {'law', 'police'},
    state 'LOCKED',
    handle 'door_saint_dennis_jail_garage_03',
    pair 'door_saint_dennis_jail_garage_04'
}
door {
    door_hash'2503834054',
    allowed_groups {'law', 'police'},
    state 'LOCKED',
    handle 'door_saint_dennis_jail_garage_04',    
    pair 'door_saint_dennis_jail_garage_03'
}
door {
    door_hash'1992193795',
    allowed_groups {'law', 'police'},
    state 'LOCKED',
    handle 'door_saint_dennis_jail_garage_05',
    pair 'door_saint_dennis_jail_garage_06'
}
door {
    door_hash'1694749582',
    allowed_groups {'law', 'police'},
    state 'LOCKED',
    handle 'door_saint_dennis_jail_garage_06',    
    pair 'door_saint_dennis_jail_garage_05'
}

door {
    door_hash'1979938193',
    allowed_groups {'law', 'police'},
    state 'LOCKED',
    handle 'door_saint_dennis_jail_garage_07',
    pair 'door_saint_dennis_jail_garage_08'
}
door {
    door_hash'1674105116',
    allowed_groups {'law', 'police'},
    state 'LOCKED',
    handle 'door_saint_dennis_jail_garage_08',    
    pair 'door_saint_dennis_jail_garage_07'
}


door {
    door_hash'3439738919',
    allowed_groups {'healer'},
    state 'LOCKED',
    handle 'door_valentine_30'
}
door {
    door_hash'925575409',
    allowed_groups {'healer'},
    state 'LOCKED',
    handle 'door_valentine_31'
}
door {
    door_hash'4091334792',
    allowed_groups {'tabacaria'},
    state 'LOCKED',
    handle 'door_cidade_fantasma_32',
    pair 'door_cidade_fantasma_33'
}
door {
    door_hash'3852416013',
    allowed_groups {'tabacaria'},
    state 'LOCKED',
    handle 'door_cidade_fantasma_33',
    pair 'door_cidade_fantasma_32'
}
door {
    door_hash'1423877126',
    allowed_groups {'admin'},
    state 'UNLOCKED',
    handle 'door_tumbleweed_34'
}
door {
    door_hash'2058564250',
    allowed_groups {'admin'},
    state 'UNLOCKED',
    handle 'door_rhodes_35'
}
door {
    door_hash '1634148892',
    allowed_groups {'admin'},
    state 'UNLOCKED',
    handle 'door_rhodes_37'
}
door {
    door_hash '1340831050',
    allowed_groups {'admin'},
    state 'UNLOCKED',
    handle 'door_valentine_38'
}
door {
    door_hash'3718620420',
    allowed_groups {'admin'},
    state 'UNLOCKED',
    handle 'door_valentine_39'
}
door {
    door_hash '334467483',
    allowed_groups {'admin'},
    state 'UNLOCKED',
    handle 'door_valentine_40'
}
door {
    door_hash'2343746133',
    allowed_groups {'admin'},
    state 'UNLOCKED',
    handle 'door_valentine_41'
}
door {
    door_hash'576950805',
    allowed_groups {'admin'},
    state 'UNLOCKED',
    handle 'door_valentine_42'
}
door {
    door_hash'3101287960',
    allowed_groups {'admin'},
    state 'UNLOCKED',
    handle 'door_armadillo_45'
}
door {
    door_hash'1634115439',
    allowed_groups {'admin'},
    state 'UNLOCKED',
    handle 'door_saint_denis_48'
}
door {
    door_hash'965922748',
    allowed_groups {'admin'},
    state 'UNLOCKED',
    handle 'door_saint_denis_49'
}
door {
    door_hash'586229709',
    allowed_groups {'admin'},
    state 'UNLOCKED',
    handle 'door_saint_denis_50'
}


