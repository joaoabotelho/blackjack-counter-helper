class PlaysController < ApplicationController
  before_action :set_play, only: [:show, :edit, :update, :destroy]

  # GET /plays
  # GET /plays.json
  def index
    @plays = Play.all
  end

  # GET /plays/1
  # GET /plays/1.json
  def show
  end

  # GET /plays/new
  def new
    dealer_hand = params[:dealer_hand].to_i
    our_hand = params[:hand]
    true_count = params[:true_count].to_i

    h = "Hit"
    s = "Stand"
    dh = "Double if allowed or Hit"
    ds = "Double if allowed or Stand"
    p = "Split"
    ph = "Split if allowed or Hit"
    rh = "Surrender if allowed or Hit"

    basic_strat = {
        # 4-8(0), 9(1), 10(2), 11(3), 12(4), 13(5), 14(6), 15(7), 16(8), +17(9)
        hard: { 2 => [h, h, dh, dh, h, s, s, s, s, s],
                3 => [h, dh, dh, dh, h, s, s, s, s, s],
                4 => [h, dh, dh, dh, s, s, s, s, s, s],
                5 => [h, dh, dh, dh, s, s, s, s, s, s],
                6 => [h, dh, dh, dh, s, s, s, s, s, s],
                7 => [h, h, dh, dh, h, h, h, h, h, s],
                8 => [h, h, dh, dh, h, h, h, h, h, s],
                9 => [h, h, dh, dh, h, h, h, h, rh, s],
                10 => [h, h, h, dh, h, h, h, rh, rh, s],
                11 => [h, h, h, h, h, h, h, h, rh, s],
        },

        # 13(0), 14(1), 15(2), 16(3), 17(4), 18(5), 19+(6)
        soft: { 2 => [h, h, h, h, h, s, s],
                3 => [h, h, h, h, dh, ds, s],
                4 => [h, h, dh, dh, dh, ds, s],
                5 => [dh, dh, dh, dh, dh, ds, s],
                6 => [dh, dh, dh, dh, dh, ds, s],
                7 => [h, h, h, h, h, s, s],
                8 => [h, h, h, h, h, s, s],
                9 => [h, h, h, h, h, h, s],
                10 => [h, h, h, h, h, h, s],
                11 => [h, h, h, h, h, h, s],
        },

        # 2.2(0), 3.3(1), 4.4(2), 6.6(3), 7.7(4), 8.8(5), 9.9(6), 10.10(7), A,A(8)
        split: { 2 => [ph, ph, h, ph, p, p, p, s, p],
                 3 => [ph, ph, h, p, p, p, p, s, p],
                 4 => [p, p, h, p, p, p, p, s, p],
                 5 => [p, p, ph, p, p, p, p, s, p],
                 6 => [p, p, ph, p, p, p, p, s, p],
                 7 => [p, p, h, h, p, p, s, s, p],
                 8 => [h, h, h, h, h, p, p, s, p],
                 9 => [h, h, h, h, h, p, p, s, p],
                 10 => [h, h, h, h, h, p, s, s, p],
                 11 => [h, h, h, h, h, p, s, s, p],
        },
    }

    if true_count >= -2
      basic_strat[:hard][3][5] = s # 13 vs 3
    else
      basic_strat[:hard][3][5] = h
    end

    if true_count >= -1
      basic_strat[:hard][2][5] = s # 13 vs 2
      basic_strat[:hard][5][4] = s # 12 vs 5
      basic_strat[:hard][6][4] = s # 12 vs 6 s
    else
      basic_strat[:hard][2][5] = h # 13 vs 2
      basic_strat[:hard][5][4] = h # 12 vs 5
      basic_strat[:hard][6][4] = h # 12 vs 6
    end

    if true_count >= 0
      basic_strat[:hard][10][8] = s #  16 vs 10
      basic_strat[:hard][4][4] = s # 12 vs 4
      basic_strat[:hard][10][7] = rh # 15 vs 10
    end

    if true_count >= 1
      basic_strat[:hard][11][3] = dh # 11 vs A dh
      basic_strat[:hard][2][1] = dh # 9 vs 2 dh
    end

    if true_count >= 2
      basic_strat[:hard][3][4] = s # 12 vs 3
      basic_strat[:hard][9][7] = rh # 15 vs 9 surrender
      basic_strat[:hard][11][7] = rh # 15 vs A surrender
    end

    if true_count >= 3
      basic_strat[:hard][10][6] = rh # 14 vs 10 surrender
    end

    if true_count >= 4
      basic_strat[:hard][10][7] = s # 15 vs 10
      basic_strat[:hard][2][4] = s # 12 vs 2(s)
      basic_strat[:hard][10][2] = dh # 10 vs 10 dh
      basic_strat[:hard][11][2] = dh # 10 vs A dh
      basic_strat[:hard][7][1] = dh # 9 vs 7 dh
    end

    if true_count >= 5
      basic_strat[:hard][9][8] = s # 16 vs 9
      basic_strat[:split][5][7] = p # 10,10 vs 5 p
      basic_strat[:split][6][7] = p # 10,10 vs 6 p
    end


    if our_hand[0,1] == 'h'

      our_hand_int = our_hand[1,2].to_i
      if our_hand_int <= 8
        index = 0
      elsif  our_hand_int >= 17
        index = 9
      else
        index = our_hand_int - 8
      end
      play = basic_strat[:hard][dealer_hand][index]

    elsif our_hand[0,1] == 's'

      our_hand_int = our_hand[1,2].to_i
      if our_hand_int >= 19
        index = 6
      else
        index = our_hand_int - 13
      end
      play = basic_strat[:soft][dealer_hand][index]

    else
      our_hand = our_hand.split(",")

      our_hand_int = our_hand[0].to_i
      if our_hand_int <= 4
        # 2.2(0), 3.3(1), 4.4(2) (-2)
       index = our_hand_int-2
      else
        # 6.6(3), 7.7(4), 8.8(5), 9.9(6), 10.10(7), 11,11(8) (-3)
        index = our_hand_int-3
      end
      play = basic_strat[:split][dealer_hand][index]
    end

    Play.create(hand: our_hand, dealer_hand:dealer_hand, play: play)
  end

  # GET /plays/1/edit
  def edit
  end

  # POST /plays
  # POST /plays.json
  def create
    @play = Play.new(play_params)

    respond_to do |format|
      if @play.save
        format.html { redirect_to @play, notice: 'Play was successfully created.' }
        format.json { render :show, status: :created, location: @play }
      else
        format.html { render :new }
        format.json { render json: @play.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plays/1
  # PATCH/PUT /plays/1.json
  def update
    respond_to do |format|
      if @play.update(play_params)
        format.html { redirect_to @play, notice: 'Play was successfully updated.' }
        format.json { render :show, status: :ok, location: @play }
      else
        format.html { render :edit }
        format.json { render json: @play.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plays/1
  # DELETE /plays/1.json
  def destroy
    @play.destroy
    respond_to do |format|
      format.html { redirect_to plays_url, notice: 'Play was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_play
      @play = Play.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def play_params
      params.require(:play).permit(:hand, :dealer_hand)
    end

end
