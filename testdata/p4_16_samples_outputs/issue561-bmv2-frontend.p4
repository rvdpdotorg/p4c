error {
    TcpDataOffsetTooSmall,
    TcpOptionTooLongForHeader,
    TcpBadSackOptionLength
}
#include <core.p4>
#include <v1model.p4>

typedef bit<48> EthernetAddress;
header ethernet_t {
    EthernetAddress dstAddr;
    EthernetAddress srcAddr;
    bit<16>         etherType;
}

header ipv4_t {
    bit<4>  version;
    bit<4>  ihl;
    bit<8>  diffserv;
    bit<16> totalLen;
    bit<16> identification;
    bit<3>  flags;
    bit<13> fragOffset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdrChecksum;
    bit<32> srcAddr;
    bit<32> dstAddr;
}

header tcp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> seqNo;
    bit<32> ackNo;
    bit<4>  dataOffset;
    bit<3>  res;
    bit<3>  ecn;
    bit<6>  ctrl;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgentPtr;
}

header Tcp_option_end_h {
    bit<8> kind;
}

header Tcp_option_nop_h {
    bit<8> kind;
}

header Tcp_option_ss_h {
    bit<8>  kind;
    bit<32> maxSegmentSize;
}

header Tcp_option_s_h {
    bit<8>  kind;
    bit<24> scale;
}

header Tcp_option_sack_h {
    bit<8>      kind;
    bit<8>      length;
    varbit<256> sack;
}

header_union Tcp_option_h {
    Tcp_option_end_h  end;
    Tcp_option_nop_h  nop;
    Tcp_option_ss_h   ss;
    Tcp_option_s_h    s;
    Tcp_option_sack_h sack;
}

typedef Tcp_option_h[10] Tcp_option_stack;
header Tcp_option_padding_h {
    varbit<256> padding;
}

struct headers {
    ethernet_t           ethernet;
    ipv4_t               ipv4;
    tcp_t                tcp;
    Tcp_option_stack     tcp_options_vec;
    Tcp_option_padding_h tcp_options_padding;
}

struct fwd_metadata_t {
    bit<32> l2ptr;
    bit<24> out_bd;
}

struct metadata {
    fwd_metadata_t fwd_metadata;
}

struct Tcp_option_sack_top {
    bit<8> kind;
    bit<8> length;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    bit<4> tcp_hdr_data_offset_0;
    Tcp_option_stack vec_0;
    Tcp_option_padding_h padding_0;
    bit<7> Tcp_option_parser_tcp_hdr_bytes_left;
    bit<8> Tcp_option_parser_n_sack_bytes;
    bit<8> Tcp_option_parser_tmp;
    Tcp_option_sack_top Tcp_option_parser_tmp_0;
    state start {
        packet.extract<ethernet_t>(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            16w0x800: parse_ipv4;
            default: accept;
        }
    }
    state parse_ipv4 {
        packet.extract<ipv4_t>(hdr.ipv4);
        transition select(hdr.ipv4.protocol) {
            8w6: parse_tcp;
            default: accept;
        }
    }
    state parse_tcp {
        packet.extract<tcp_t>(hdr.tcp);
        tcp_hdr_data_offset_0 = hdr.tcp.dataOffset;
        vec_0[0].end.setInvalid();
        vec_0[0].nop.setInvalid();
        vec_0[0].ss.setInvalid();
        vec_0[0].s.setInvalid();
        vec_0[0].sack.setInvalid();
        vec_0[1].end.setInvalid();
        vec_0[1].nop.setInvalid();
        vec_0[1].ss.setInvalid();
        vec_0[1].s.setInvalid();
        vec_0[1].sack.setInvalid();
        vec_0[2].end.setInvalid();
        vec_0[2].nop.setInvalid();
        vec_0[2].ss.setInvalid();
        vec_0[2].s.setInvalid();
        vec_0[2].sack.setInvalid();
        vec_0[3].end.setInvalid();
        vec_0[3].nop.setInvalid();
        vec_0[3].ss.setInvalid();
        vec_0[3].s.setInvalid();
        vec_0[3].sack.setInvalid();
        vec_0[4].end.setInvalid();
        vec_0[4].nop.setInvalid();
        vec_0[4].ss.setInvalid();
        vec_0[4].s.setInvalid();
        vec_0[4].sack.setInvalid();
        vec_0[5].end.setInvalid();
        vec_0[5].nop.setInvalid();
        vec_0[5].ss.setInvalid();
        vec_0[5].s.setInvalid();
        vec_0[5].sack.setInvalid();
        vec_0[6].end.setInvalid();
        vec_0[6].nop.setInvalid();
        vec_0[6].ss.setInvalid();
        vec_0[6].s.setInvalid();
        vec_0[6].sack.setInvalid();
        vec_0[7].end.setInvalid();
        vec_0[7].nop.setInvalid();
        vec_0[7].ss.setInvalid();
        vec_0[7].s.setInvalid();
        vec_0[7].sack.setInvalid();
        vec_0[8].end.setInvalid();
        vec_0[8].nop.setInvalid();
        vec_0[8].ss.setInvalid();
        vec_0[8].s.setInvalid();
        vec_0[8].sack.setInvalid();
        vec_0[9].end.setInvalid();
        vec_0[9].nop.setInvalid();
        vec_0[9].ss.setInvalid();
        vec_0[9].s.setInvalid();
        vec_0[9].sack.setInvalid();
        padding_0.setInvalid();
        transition Tcp_option_parser_start;
    }
    state Tcp_option_parser_start {
        verify(tcp_hdr_data_offset_0 >= 4w5, error.TcpDataOffsetTooSmall);
        Tcp_option_parser_tcp_hdr_bytes_left = (bit<7>)(tcp_hdr_data_offset_0 + 4w11) << 2;
        transition Tcp_option_parser_next_option;
    }
    state Tcp_option_parser_next_option {
        transition select(Tcp_option_parser_tcp_hdr_bytes_left) {
            7w0: parse_tcp_0;
            default: Tcp_option_parser_next_option_part2;
        }
    }
    state Tcp_option_parser_next_option_part2 {
        Tcp_option_parser_tmp = packet.lookahead<bit<8>>();
        transition select(Tcp_option_parser_tmp) {
            8w0: Tcp_option_parser_parse_tcp_option_end;
            8w1: Tcp_option_parser_parse_tcp_option_nop;
            8w2: Tcp_option_parser_parse_tcp_option_ss;
            8w3: Tcp_option_parser_parse_tcp_option_s;
            8w5: Tcp_option_parser_parse_tcp_option_sack;
        }
    }
    state Tcp_option_parser_parse_tcp_option_end {
        packet.extract<Tcp_option_end_h>(vec_0.next.end);
        Tcp_option_parser_tcp_hdr_bytes_left = Tcp_option_parser_tcp_hdr_bytes_left + 7w127;
        packet.extract<Tcp_option_padding_h>(padding_0, (bit<32>)((bit<9>)Tcp_option_parser_tcp_hdr_bytes_left << 3));
        transition parse_tcp_0;
    }
    state Tcp_option_parser_parse_tcp_option_nop {
        packet.extract<Tcp_option_nop_h>(vec_0.next.nop);
        Tcp_option_parser_tcp_hdr_bytes_left = Tcp_option_parser_tcp_hdr_bytes_left + 7w127;
        transition Tcp_option_parser_next_option;
    }
    state Tcp_option_parser_parse_tcp_option_ss {
        verify(Tcp_option_parser_tcp_hdr_bytes_left >= 7w5, error.TcpOptionTooLongForHeader);
        Tcp_option_parser_tcp_hdr_bytes_left = Tcp_option_parser_tcp_hdr_bytes_left + 7w123;
        packet.extract<Tcp_option_ss_h>(vec_0.next.ss);
        transition Tcp_option_parser_next_option;
    }
    state Tcp_option_parser_parse_tcp_option_s {
        verify(Tcp_option_parser_tcp_hdr_bytes_left >= 7w4, error.TcpOptionTooLongForHeader);
        Tcp_option_parser_tcp_hdr_bytes_left = Tcp_option_parser_tcp_hdr_bytes_left + 7w124;
        packet.extract<Tcp_option_s_h>(vec_0.next.s);
        transition Tcp_option_parser_next_option;
    }
    state Tcp_option_parser_parse_tcp_option_sack {
        Tcp_option_parser_tmp_0 = packet.lookahead<Tcp_option_sack_top>();
        Tcp_option_parser_n_sack_bytes = Tcp_option_parser_tmp_0.length;
        verify(Tcp_option_parser_n_sack_bytes == 8w10 || Tcp_option_parser_n_sack_bytes == 8w18 || Tcp_option_parser_n_sack_bytes == 8w26 || Tcp_option_parser_n_sack_bytes == 8w34, error.TcpBadSackOptionLength);
        verify(Tcp_option_parser_tcp_hdr_bytes_left >= (bit<7>)Tcp_option_parser_n_sack_bytes, error.TcpOptionTooLongForHeader);
        Tcp_option_parser_tcp_hdr_bytes_left = Tcp_option_parser_tcp_hdr_bytes_left - (bit<7>)Tcp_option_parser_n_sack_bytes;
        packet.extract<Tcp_option_sack_h>(vec_0.next.sack, (bit<32>)((Tcp_option_parser_n_sack_bytes << 3) + 8w240));
        transition Tcp_option_parser_next_option;
    }
    state parse_tcp_0 {
        hdr.tcp_options_vec = vec_0;
        hdr.tcp_options_padding = padding_0;
        transition accept;
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".my_drop") action my_drop() {
        mark_to_drop();
    }
    @name(".my_drop") action my_drop_0() {
        mark_to_drop();
    }
    @name("ingress.set_l2ptr") action set_l2ptr(bit<32> l2ptr) {
        meta.fwd_metadata.l2ptr = l2ptr;
    }
    @name("ingress.ipv4_da_lpm") table ipv4_da_lpm_0 {
        key = {
            hdr.ipv4.dstAddr: lpm @name("hdr.ipv4.dstAddr") ;
        }
        actions = {
            set_l2ptr();
            my_drop();
        }
        default_action = my_drop();
    }
    @name("ingress.set_bd_dmac_intf") action set_bd_dmac_intf(bit<24> bd, bit<48> dmac, bit<9> intf) {
        meta.fwd_metadata.out_bd = bd;
        hdr.ethernet.dstAddr = dmac;
        standard_metadata.egress_spec = intf;
        hdr.ipv4.ttl = hdr.ipv4.ttl + 8w255;
    }
    @name("ingress.mac_da") table mac_da_0 {
        key = {
            meta.fwd_metadata.l2ptr: exact @name("meta.fwd_metadata.l2ptr") ;
        }
        actions = {
            set_bd_dmac_intf();
            my_drop_0();
        }
        default_action = my_drop_0();
    }
    apply {
        ipv4_da_lpm_0.apply();
        mac_da_0.apply();
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".my_drop") action my_drop_1() {
        mark_to_drop();
    }
    @name("egress.rewrite_mac") action rewrite_mac(bit<48> smac) {
        hdr.ethernet.srcAddr = smac;
    }
    @name("egress.send_frame") table send_frame_0 {
        key = {
            meta.fwd_metadata.out_bd: exact @name("meta.fwd_metadata.out_bd") ;
        }
        actions = {
            rewrite_mac();
            my_drop_1();
        }
        default_action = my_drop_1();
    }
    apply {
        send_frame_0.apply();
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit<ethernet_t>(hdr.ethernet);
        packet.emit<ipv4_t>(hdr.ipv4);
        packet.emit<tcp_t>(hdr.tcp);
        packet.emit<Tcp_option_h[10]>(hdr.tcp_options_vec);
        packet.emit<Tcp_option_padding_h>(hdr.tcp_options_padding);
    }
}

control verifyChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

V1Switch<headers, metadata>(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;

