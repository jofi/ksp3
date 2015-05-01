class Dlazdica
  attr_reader :riadok, :stlpec, :hodnota

  def initialize(chodba, riadok, stlpec, hodnota)
    @chodba = chodba
    @riadok = riadok
    @stlpec = stlpec
    @hodnota = hodnota
  end

  def dlazdica_nad
    @dlazdica_nad ||= @chodba.dlazdica(@riadok - 1, @stlpec)
    @dlazdica_nad
  end

  def dlazdica_vlavo
    @dlazdica_vlavo ||= @chodba.dlazdica(@riadok, @stlpec - 1)
    @dlazdica_vlavo
  end

  def suma
    if !lepsi_sused
      @suma ||= @hodnota
    else
      @suma ||= lepsi_sused.suma + @hodnota
    end
    @suma
  end

  def smer
    if (@riadok == 1) && (@stlpec == 1)
      @smer ||= '-'
    end
    @smer ||= begin
      vlavo = dlazdica_vlavo ? dlazdica_vlavo.hodnota : 0
      nad = dlazdica_nad ? dlazdica_nad.hodnota : 0
      vlavo > nad ? 'R' : 'D'
    end
    @smer
  end

  def lepsi_sused
    @lepsi_sused ||= begin
      vlavo = dlazdica_vlavo ? dlazdica_vlavo.hodnota : 0
      nad = dlazdica_nad ? dlazdica_nad.hodnota : 0
      vlavo > nad ? dlazdica_vlavo : dlazdica_nad
    end
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
      return nil #Chodba.prazdna_dlazdica(self)
    end
    @dlazdice[riadok - 1][stlpec - 1]
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

  def vypis_cestu
    puts cesta.join(' ')
  end
end


vstup = ARGV[0]
@chodba = nil
prvy_riadok = 0

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
@chodba.vypis_cestu
