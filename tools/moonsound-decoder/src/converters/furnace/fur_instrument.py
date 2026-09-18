"""Furnace FM instrument definitions.

Encodes instruments using Furnace's modern self-describing "INS2" format
(src/engine/instrument.cpp: DivInstrument::readInsDataNew /
readFeatureNA / readFeatureFM), reverse-engineered from the actual
Furnace source and verified by loading output in the real Furnace
binary. This format is feature-tag based (2-byte code + 2-byte length +
payload) so it tolerates being read by many format-version reader
builds without per-version field gating, unlike the legacy "INST"
layout.
"""

from dataclasses import dataclass, field
from typing import List
import struct


DIV_INS_OPL = 14


def _feature(code: bytes, payload: bytes) -> bytes:
    """Wrap payload as a length-prefixed Furnace instrument feature block."""
    assert len(code) == 2
    return code + struct.pack('<H', len(payload)) + payload


@dataclass
class FurFMOperator:
    """Single FM operator for OPL-series chips."""
    am: int = 0       # Amplitude modulation enable (0-1)
    vib: int = 0      # Vibrato enable (0-1)
    sus: int = 0      # Sustain/EG type (0-1)
    ksr: int = 0      # Key scale rate (0-1)
    mult: int = 1     # Frequency multiplier (0-15)
    ksl: int = 0      # Key scale level (0-3)
    tl: int = 63      # Total level / volume (0-63, 63=silent)
    ar: int = 15      # Attack rate (0-15)
    dr: int = 0       # Decay rate (0-15)
    sl: int = 15      # Sustain level (0-15)
    rr: int = 15      # Release rate (0-15)
    ws: int = 0       # Waveform select (0-7 for OPL3/4)

    def to_furnace_bytes(self) -> bytes:
        """Encode as one DivInstrumentFM::Operator record (8 bytes),
        per readFeatureFM in instrument.cpp."""
        return bytes([
            (1 if self.ksr else 0) << 7 | (0 << 4) | (self.mult & 0x0F),
            (1 if self.sus else 0) << 7 | (self.tl & 0x7F),
            (0 << 6) | (1 if self.vib else 0) << 5 | (self.ar & 0x1F),
            (1 if self.am else 0) << 7 | (self.ksl & 3) << 5 | (self.dr & 0x1F),
            0,  # egt/kvs/d2r: unused for OPL
            (self.sl & 0x0F) << 4 | (self.rr & 0x0F),
            0,  # dvb/ssgEnv: unused for OPL
            (0 << 5) | (0 << 3) | (self.ws & 0x07),
        ])

    @classmethod
    def from_mfm_bytes(cls, data: bytes, offset: int = 0) -> 'FurFMOperator':
        """Parse from MFM instrument data (11-byte operator pair format)."""
        return cls(
            am=(data[offset] >> 7) & 1,
            vib=(data[offset] >> 6) & 1,
            sus=(data[offset] >> 5) & 1,
            ksr=(data[offset] >> 4) & 1,
            mult=data[offset] & 0x0F,
            ksl=(data[offset + 2] >> 6) & 3,
            tl=data[offset + 2] & 0x3F,
            ar=(data[offset + 4] >> 4) & 0x0F,
            dr=data[offset + 4] & 0x0F,
            sl=(data[offset + 6] >> 4) & 0x0F,
            rr=data[offset + 6] & 0x0F,
            ws=data[offset + 8] & 0x07,
        )


@dataclass
class FurFMInstrument:
    """FM instrument for Furnace (OPL-type, DIV_INS_OPL)."""
    name: str = ""
    operators: List[FurFMOperator] = field(default_factory=list)
    feedback: int = 0     # 0-7
    connection: int = 0   # algorithm (0=FM, 1=AM)
    four_op: bool = False

    def __post_init__(self):
        if not self.operators:
            self.operators = [FurFMOperator(), FurFMOperator()]

    def to_furnace_bytes(self) -> bytes:
        """Encode instrument as an "INS2" block body (i.e. everything
        after the 4-byte "INS2" magic): dataLen(I) formatVersion(S)
        type(S) [feature]* "EN"+len(0).
        """
        op_count = len(self.operators)

        na_feat = _feature(b"NA", self.name.encode('utf-8', errors='replace') + b"\x00")

        fm_payload = bytearray()
        enable_bits = 0
        for i in range(min(op_count, 4)):
            enable_bits |= (1 << (4 + i))
        fm_payload.append(enable_bits | (op_count & 0x0F))
        fm_payload.append(((self.connection & 7) << 4) | (self.feedback & 7))
        fm_payload.append(0)  # fms2/ams/fms: unused for OPL
        ops_flag = 0x20 if op_count >= 4 else 0x00
        fm_payload.append(ops_flag)  # ams2/ops/opllPreset
        for op in self.operators:
            fm_payload.extend(op.to_furnace_bytes())
        fm_feat = _feature(b"FM", bytes(fm_payload))

        en_feat = b"EN" + struct.pack('<H', 0)

        body = bytearray()
        body.extend(struct.pack('<H', 0))            # format version (ignored on read)
        body.extend(struct.pack('<H', DIV_INS_OPL))   # instrument type
        body.extend(na_feat)
        body.extend(fm_feat)
        body.extend(en_feat)

        result = bytearray()
        result.extend(struct.pack('<I', len(body)))
        result.extend(body)
        return bytes(result)

    @staticmethod
    def _op_from_patch_half(am_vib_eg_ksr_mult: int, ksl_tl: int, ar_dr: int,
                             sl_rr: int, waveform: int) -> 'FurFMOperator':
        """Decode one OPL operator (mod or car half of an 11-byte MFM
        patch) from its 5 raw register bytes. Bit layout matches real
        OPL registers 0x20/0x40/0x60/0x80/0xE0 exactly (cross-checked
        against src/converters/vgm/vgm_writer.py, which forwards these
        same raw bytes untouched to real OPL4 register writes)."""
        return FurFMOperator(
            am=(am_vib_eg_ksr_mult >> 7) & 1,
            vib=(am_vib_eg_ksr_mult >> 6) & 1,
            sus=(am_vib_eg_ksr_mult >> 5) & 1,
            ksr=(am_vib_eg_ksr_mult >> 4) & 1,
            mult=am_vib_eg_ksr_mult & 0x0F,
            ksl=(ksl_tl >> 6) & 3,
            tl=ksl_tl & 0x3F,
            ar=(ar_dr >> 4) & 0x0F,
            dr=ar_dr & 0x0F,
            sl=(sl_rr >> 4) & 0x0F,
            rr=sl_rr & 0x0F,
            ws=waveform & 0x07,
        )

    @classmethod
    def from_mfm_instrument(cls, mfm_inst, name: str = "") -> 'FurFMInstrument':
        """Convert MFM instrument to a 2-operator Furnace instrument,
        using only the primary (operators 1+2) patch."""
        primary = mfm_inst.primary

        mod_op = cls._op_from_patch_half(
            primary.mod_am_vib_eg_ksr_mult, primary.mod_ksl_tl,
            primary.mod_ar_dr, primary.mod_sl_rr, primary.mod_waveform)
        car_op = cls._op_from_patch_half(
            primary.car_am_vib_eg_ksr_mult, primary.car_ksl_tl,
            primary.car_ar_dr, primary.car_sl_rr, primary.car_waveform)

        feedback = (primary.feedback_connection >> 1) & 0x07
        connection = primary.feedback_connection & 0x01

        return cls(
            name=name,
            operators=[mod_op, car_op],
            feedback=feedback,
            connection=connection,
            four_op=False,
        )

    @classmethod
    def from_mfm_instrument_4op(cls, mfm_inst, name: str = "") -> 'FurFMInstrument':
        """Convert MFM instrument to a 4-operator Furnace instrument,
        combining the primary (op 1+2) and secondary (op 3+4) patches.

        Operator storage order and the combined algorithm formula are
        derived from Furnace's real OPL dispatch (src/engine/platform/opl.cpp):
        `orderedOpsL[4]={0,2,1,3}` is applied as
        `op[(ops==4) ? orderedOpsL[j] : j]` when iterating hardware
        register slots j=0..3 in [masterMod, masterCar, slaveMod, slaveCar]
        order, which back-solves to storage order
        [Op1(masterMod), Op3(slaveMod), Op2(masterCar), Op4(slaveCar)].
        The algorithm is combined from each pair's own connection (CNT)
        bit as `alg = CNT1 | (CNT2<<1)` (isOutputL[1][alg] table in the
        same source confirms alg 0-3 = the 4 standard 4-op OPL3 routings).
        Feedback uses only the primary (master) pair's value, matching
        real OPL3 semantics where feedback only applies to an operator
        with no modulation input (i.e. operator 1).
        """
        primary = mfm_inst.primary
        secondary = mfm_inst.secondary

        op1_master_mod = cls._op_from_patch_half(
            primary.mod_am_vib_eg_ksr_mult, primary.mod_ksl_tl,
            primary.mod_ar_dr, primary.mod_sl_rr, primary.mod_waveform)
        op2_master_car = cls._op_from_patch_half(
            primary.car_am_vib_eg_ksr_mult, primary.car_ksl_tl,
            primary.car_ar_dr, primary.car_sl_rr, primary.car_waveform)
        op3_slave_mod = cls._op_from_patch_half(
            secondary.mod_am_vib_eg_ksr_mult, secondary.mod_ksl_tl,
            secondary.mod_ar_dr, secondary.mod_sl_rr, secondary.mod_waveform)
        op4_slave_car = cls._op_from_patch_half(
            secondary.car_am_vib_eg_ksr_mult, secondary.car_ksl_tl,
            secondary.car_ar_dr, secondary.car_sl_rr, secondary.car_waveform)

        cnt1 = primary.feedback_connection & 0x01
        cnt2 = secondary.feedback_connection & 0x01
        algorithm = cnt1 | (cnt2 << 1)
        feedback = (primary.feedback_connection >> 1) & 0x07

        return cls(
            name=name,
            operators=[op1_master_mod, op3_slave_mod, op2_master_car, op4_slave_car],
            feedback=feedback,
            connection=algorithm,
            four_op=True,
        )
