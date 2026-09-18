"""
MoonSound Python Toolset

Comprehensive tools for parsing and analyzing MoonSound audio files:
- OPL4 FM synthesis decoder (OPL3-compatible)
- OPL4 PCM/Wavetable synthesis decoder
- MFM (MoonBlaster FM Music) file parser
- MWM (MoonBlaster Wave Music) file parser

Based on Yamaha YMF278B (OPL4) documentation and MoonBlaster file format specs.
"""

__version__ = "1.0.0"
__author__ = "ZXM-MoonSound Project"

from .opl4_fm import OPL4FMDecoder, FMChannel, FMOperator, FMGlobalState
from .opl4_pcm import OPL4PCMDecoder, PCMChannel, PCMEnvelope, PCMLFO, PCMGlobalState
from .mfm_parser import MFMParser, MFMFile
from .mwm_parser import MWMParser, MWMFile

__all__ = [
    # FM
    'OPL4FMDecoder',
    'FMChannel',
    'FMOperator',
    'FMGlobalState',
    # PCM
    'OPL4PCMDecoder',
    'PCMChannel',
    'PCMEnvelope',
    'PCMLFO',
    'PCMGlobalState',
    # File parsers
    'MFMParser',
    'MFMFile',
    'MWMParser',
    'MWMFile',
]
