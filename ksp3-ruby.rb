vstup = ARGV[0]
vystup = ARGV[1]

chodba = []
vysledky = []

prvy_riadok = true
cislo_riadku = 0
cislo_stlpca = 0

class Dlazdica
  attr_reader :riadok, :stlpec, :hodnota

  def initialize(chodba, riadok, stlpec, hodnota)
    @chodba = chodba
    @riadok = riadok
    @stlpec = stlpec
    @hodnota = hodnota
  end

  def dlazdica_nad
    @chodba.dlazdica(@riadok - 1, @stlpec)
  end

  def dlazdica_vlavo
    @chodba.dlazdica(@riadok, @stlpec - 1)
  end

  def suma
    if (@riadok == 0) || (@stlpec == 0)
      return 0
    end
    @suma = lepsi_sused.suma + @hodnota
    @suma
  end

  def smer
    if (@riadok == 0) || (@stlpec == 0)
      return ''
    end
    @smer ||= dlazdica_vlavo.hodnota > dlazdica_nad.hodnota ? 'R' : 'D'
    @smer
  end

  def lepsi_sused
    if (@riadok == 0) || (@stlpec == 0)
      return nil
    end
    @lepsi_sused ||= dlazdica_vlavo.hodnota > dlazdica_nad.hodnota ? dlazdica_vlavo : dlazdica_nad
    @lepsi_sused
  end

end

class Chodba

  def self.prazdna_dlazdica(chodba)
    @@prazdna ||= Dlazdica.new(chodba, 0,0,0)
    @@prazdna
  end

  def initialize(riadkov, stlpcov)
    @dlazdice = []
    @riadkov = riadkov
    @stlpcov = stlpcov
  end

  def pridaj_riadok(riadok)
    @dlazdice << Array.new(0)
    cislo_stlpca = 1
    posl_riadok = @dlazdice.length
    riadok.each do |hodnota|
      @dlazdice[posl_riadok - 1] << Dlazdica.new(self, posl_riadok, cislo_stlpca, hodnota.to_i)
      cislo_stlpca += 1
    end
  end

  def dlazdica(riadok, stlpec)
    if (riadok == 0) || (stlpec == 0)
      return Chodba.prazdna_dlazdica(self)
    end
    @dlazdice[riadok - 1][stlpec - 1]
  end

  def vypis_dlazdice(&block)
    @dlazdice.each do |row|
      row.each do |col|
        block.call(col)
      end
      puts
    end
  end

  def vypis_hodnoty
    vypis_dlazdice do |dlazdica|
        printf("%3d", dlazdica.hodnota)
    end
  end

  def vypis_sumy
    vypis_dlazdice do |dlazdica|
        printf("%3d", dlazdica.suma)
    end
  end

  def vypis_smery
    vypis_dlazdice do |dlazdica|
        printf("%3s", dlazdica.smer)
    end
  end

  def cesta
    cesta_odzadu = []
    dlazdica = dlazdica(@riadkov, @stlpcov)
    while dlazdica
      cesta_odzadu << dlazdica.smer
      dlazdica = dlazdica.lepsi_sused
    end

    cesta_odzadu.reverse
  end
end


@chodba = nil

File.open(vstup, 'r').each do |akt_riadok|
  if prvy_riadok
    riadkov, stlpcov = akt_riadok.split(' ')
    @chodba = Chodba.new(riadkov.to_i, stlpcov.to_i)
    prvy_riadok = false
    next
  end
  @chodba.pridaj_riadok(akt_riadok.split(' '))
end

@chodba.vypis_hodnoty
puts
@chodba.vypis_sumy
puts
@chodba.vypis_smery
puts
puts @chodba.cesta
